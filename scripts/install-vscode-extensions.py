#!/usr/bin/env python3

from __future__ import annotations

import json
import shutil
import subprocess
import sys
import tempfile
import urllib.error
import urllib.parse
import urllib.request
import zipfile
from pathlib import Path
from typing import NoReturn

RED = "\033[0;31m"
GREEN = "\033[0;32m"
YELLOW = "\033[1;33m"
NC = "\033[0m"


def echo(message: str) -> None:
    print(message)


def eecho(message: str) -> None:
    print(message, file=sys.stderr)


def fail(message: str, *, exit_code: int = 1) -> NoReturn:
    echo(f"{RED}Error: {message}{NC}")
    raise SystemExit(exit_code)


def prompt_from_tty(prompt: str) -> str:
    if sys.stdin.isatty():
        try:
            return input(prompt)
        except EOFError:
            return ""

    try:
        with open("/dev/tty", "r+", encoding="utf-8", errors="replace") as tty:
            tty.write(prompt)
            tty.flush()
            return tty.readline().strip()
    except OSError:
        return ""


def check_code_cli() -> None:
    if shutil.which("code") is None:
        fail(
            "VSCode CLI (code) is not installed.\n"
            "Please install VSCode and ensure 'code' command is available in PATH.\n"
            "You can install it from: https://code.visualstudio.com/"
        )


def fetch_json(url: str, headers: dict[str, str] | None = None) -> dict:
    request = urllib.request.Request(url, headers=headers or {})
    try:
        with urllib.request.urlopen(request) as response:
            return json.load(response)
    except (urllib.error.URLError, json.JSONDecodeError) as exc:
        raise RuntimeError(str(exc)) from exc


def resolve_github_latest(entry: str) -> str:
    spec = entry.removeprefix("github:")
    api_url = f"https://api.github.com/repos/{spec}/releases/latest"

    eecho(f"{YELLOW}Fetching latest GitHub release for {spec}...{NC}")
    try:
        response = fetch_json(
            api_url,
            headers={
                "Accept": "application/vnd.github+json",
                "X-GitHub-Api-Version": "2022-11-28",
            },
        )
    except RuntimeError as exc:
        raise RuntimeError(f"Failed to fetch release info from GitHub for {spec}: {exc}") from exc

    for asset in response.get("assets", []):
        download_url = asset.get("browser_download_url", "")
        if download_url.endswith(".vsix"):
            return download_url

    raise RuntimeError(f"No .vsix asset found in latest release for {spec}")


def resolve_openvsx_latest(entry: str) -> str:
    spec = entry.removeprefix("openvsx:")
    if "/" in spec:
        publisher, name = spec.split("/", 1)
    else:
        publisher, name = spec.split(".", 1)

    api_url = f"https://open-vsx.org/api/{publisher}/{name}"
    eecho(f"{YELLOW}Fetching latest OpenVSX release for {publisher}.{name}...{NC}")

    try:
        response = fetch_json(api_url)
    except RuntimeError as exc:
        raise RuntimeError(
            f"Failed to fetch extension info from OpenVSX for {publisher}.{name}: {exc}"
        ) from exc

    download_url = response.get("files", {}).get("download", "")
    if not download_url:
        raise RuntimeError(f"Could not find download URL in OpenVSX response for {publisher}.{name}")
    return download_url


def get_extension_id(vsix_path: Path) -> str | None:
    try:
        with zipfile.ZipFile(vsix_path) as archive:
            with archive.open("extension/package.json") as package_file:
                package = json.load(package_file)
    except (KeyError, OSError, zipfile.BadZipFile, json.JSONDecodeError):
        return None

    publisher = package.get("publisher")
    name = package.get("name")
    if not publisher or not name:
        return None
    return f"{publisher}.{name}"


def get_installed_extensions() -> set[str]:
    result = subprocess.run(
        ["code", "--list-extensions"],
        check=True,
        text=True,
        capture_output=True,
    )
    return {line.strip().lower() for line in result.stdout.splitlines() if line.strip()}


def is_extension_installed(installed_extensions: set[str], extension_id: str) -> bool:
    return extension_id.lower() in installed_extensions


def download_file(url: str, destination: Path) -> None:
    request = urllib.request.Request(url)
    try:
        with urllib.request.urlopen(request) as response, destination.open("wb") as output:
            shutil.copyfileobj(response, output)
    except urllib.error.URLError as exc:
        raise RuntimeError(f"Failed to download from {url}: {exc}") from exc


def install_extension_file(vsix_path: Path, *, force: bool = False) -> None:
    command = ["code", "--install-extension", str(vsix_path)]
    if force:
        command.append("--force")
    subprocess.run(command, check=True)


def install_from_url(url: str, installed_extensions: set[str]) -> None:
    parsed_url = urllib.parse.urlparse(url)
    filename = Path(parsed_url.path).name
    if not filename:
        raise RuntimeError(f"Could not determine filename from URL: {url}")

    echo(f"{YELLOW}Downloading: {filename}{NC}")

    with tempfile.TemporaryDirectory() as tmpdir:
        temp_dir = Path(tmpdir)
        download_file_path = temp_dir / filename
        download_file(url, download_file_path)

        suffix = download_file_path.suffix.lower()
        if suffix == ".vsix":
            vsix_path = download_file_path
        elif suffix == ".zip":
            echo(f"{YELLOW}Extracting ZIP file...{NC}")
            extracted_dir = temp_dir / "extracted"
            with zipfile.ZipFile(download_file_path) as archive:
                archive.extractall(extracted_dir)
            matches = sorted(extracted_dir.rglob("*.vsix"))
            if not matches:
                raise RuntimeError("No .vsix file found in ZIP archive")
            vsix_path = matches[0]
        else:
            raise RuntimeError("Unsupported file format. Expected .vsix or .zip")

        extension_id = get_extension_id(vsix_path)
        if extension_id is None:
            echo(f"{YELLOW}Warning: Could not determine extension ID, attempting installation anyway{NC}")
            echo(f"{GREEN}Installing extension from {vsix_path}...{NC}")
            install_extension_file(vsix_path)
            return

        echo(f"{GREEN}Extension ID: {extension_id}{NC}")
        if is_extension_installed(installed_extensions, extension_id):
            echo(f"{YELLOW}Extension {extension_id} is already installed.{NC}")
            response = prompt_from_tty("Reinstall? [y/N] ")
            if response.lower() in {"y", "yes"}:
                echo(f"{GREEN}Reinstalling extension...{NC}")
                install_extension_file(vsix_path, force=True)
            else:
                echo(f"{YELLOW}Skipping installation.{NC}")
                return
        else:
            echo(f"{GREEN}Installing extension {extension_id}...{NC}")
            install_extension_file(vsix_path)

        installed_extensions.add(extension_id.lower())


def resolve_entry(entry: str) -> str:
    if entry.startswith("github:"):
        url = resolve_github_latest(entry)
        echo(f"{GREEN}Resolved URL: {url}{NC}")
        return url
    if entry.startswith("openvsx:"):
        url = resolve_openvsx_latest(entry)
        echo(f"{GREEN}Resolved URL: {url}{NC}")
        return url
    return entry


def iter_entries(plugins_file: Path) -> list[str]:
    entries: list[str] = []
    for line in plugins_file.read_text(encoding="utf-8").splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        compact = "".join(stripped.split())
        if compact:
            entries.append(compact)
    return entries


def main() -> int:
    plugins_file = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("assets/vscode/plugins.txt")

    echo(f"{GREEN}VSCode Extension Installer{NC}")
    echo("==========================")

    check_code_cli()

    if not plugins_file.is_file():
        fail(f"Plugins file not found: {plugins_file}")

    echo(f"{GREEN}Reading extension list from: {plugins_file}{NC}")
    installed_extensions = get_installed_extensions()

    count = 0
    for entry in iter_entries(plugins_file):
        count += 1
        echo("")
        echo(f"{GREEN}[{count}] Processing: {entry}{NC}")
        try:
            install_from_url(resolve_entry(entry), installed_extensions)
        except (RuntimeError, subprocess.CalledProcessError, ValueError) as exc:
            echo(f"{RED}Failed to install extension from {entry}: {exc}{NC}")

    echo("")
    echo(f"{GREEN}Extension installation complete!{NC}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

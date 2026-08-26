-- Define your modifier keys in one place for easy changing
local mods = { "cmd", "alt", "shift", "ctrl" } -- Change this line to modify all shortcuts at once

-- General Shortcuts for Applications
local appShortcuts = {
	-- Key, Application
	-- { "return", "iTerm" },
	-- { "return", "kitty" },
	{ "return", "Ghostty" },
	{ "E", "Finder" },
	-- { "B", "Google Chrome" },
	-- { "B", "Firefox" },
	{ "B", "Brave Browser" },
	-- { "B", "Vivaldi" },
	{ "P", "Bitwarden" },
	-- { "P", "Proton Pass" },
	-- { "P", "KeePassXC" },
	{ "W", "WeChat" },
	{ "C", "Visual Studio Code" },
	-- { "C", "Cursor" },
	-- { "C", "Windsurf" },
	-- { "C", "Antigravity" },
	{ "T", "TickTick" },
	{ "S", "Spotify" },
	{ "O", "OpenInTerminal-Lite" },
}

-- General Shortcuts for Links
local linkShortcuts = {
	-- Key, Description, URL
	{ "N", "Notion", "https://app.notion.com/" },
	-- { "D", "DeepSeek", "https://chat.deepseek.com/" },
	{ "G", "ChatGPT", "https://chatgpt.com/" },
	-- { "G", "Gemini", "https://gemini.google.com/" },
	-- { "G", "Claude", "https://claude.ai/" },
}

-- Function to display notification and open an application
local function notifyAndLaunchApp(appName)
	local success = hs.application.launchOrFocus(appName)
	-- if success then
	-- 	hs.notify.new({ title = "Hammerspoon", informativeText = "Launched " .. appName }):send()
	-- else
	-- 	hs.notify.new({ title = "Hammerspoon", informativeText = "Failed to launch " .. appName }):send()
	-- end
	if not success then
		hs.notify.new({ title = "Hammerspoon", informativeText = "Failed to launch " .. appName }):send()
	end
end

-- Function to display notification and open a URL
local function notifyAndOpenURL(description, url)
	-- hs.notify.new({ title = "Hammerspoon", informativeText = "Opening " .. description }):send()
	local success = hs.urlevent.openURL(url)
	if not success then
		hs.notify.new({ title = "Hammerspoon", informativeText = "Failed to open " .. description }):send()
	end
end

-- Create shortcuts for each application
for _, app in ipairs(appShortcuts) do
	hs.hotkey.bind(mods, app[1], function()
		notifyAndLaunchApp(app[2])
	end)
end

-- Create shortcuts for each link
for _, link in ipairs(linkShortcuts) do
	hs.hotkey.bind(mods, link[1], function()
		notifyAndOpenURL(link[2], link[3])
	end)
end

-- Other Shortcuts

-- -- Bind mods+T to OpenInTerminal-Lite in Finder and Terminal Emulator elsewhere
-- hs.hotkey.bind(mods, "return", function()
-- 	-- Check if Finder is the focused application
-- 	local frontApp = hs.application.frontmostApplication()
-- 	if frontApp:name() == "Finder" then
-- 		notifyAndLaunchApp("OpenInTerminal-Lite")
-- 	else
-- 		-- notifyAndLaunchApp("iTerm")
-- 		-- notifyAndLaunchApp("kitty")
-- 		notifyAndLaunchApp("Ghostty")
-- 	end
-- end)

-- Reload Hammerspoon config with mods+R
-- NOTE: One important detail to call out here is that hs.reload() destroys the current Lua interpreter and creates a
-- new one. If we had any code after hs.reload() in this function, it would not be called.
hs.hotkey.bind(mods, "R", function()
	hs.reload()
end)
-- Show notification after reload
hs.alert.show("Hammerspoon config loaded")

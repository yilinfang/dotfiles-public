-- Define your modifier keys in one place for easy changing
-- (Karabiner maps Caps Lock to ctrl+alt+shift)
local hyper = { 'ctrl', 'alt', 'shift' } -- Change this line to modify all shortcuts at once
local hyperCmd = { 'ctrl', 'alt', 'shift', 'cmd' } -- hyper + cmd, for extra shortcuts

-- Helpers ---------------------------------------------------------------------

-- Function to display a notification
local function notify(message)
  hs.notify.new({ title = 'Hammerspoon', informativeText = message }):send()
end

-- Function to open an application, with a notification on failure
local function launch(app)
  return function()
    if hs.application.launchOrFocus(app) then
      -- notify('Launched ' .. app)
    else
      notify('Failed to launch ' .. app)
    end
  end
end

-- Function to open a URL, with a notification on failure
local function open(url)
  return function()
    -- notify('Opening ' .. url)
    if not hs.urlevent.openURL(url) then
      notify('Failed to open ' .. url)
    end
  end
end

-- Toggle keep-mac-awake (caffeinate -dimsu)
-- Hammerspoon does not load the shell PATH, so use the absolute path.
local keepMacAwake = os.getenv('HOME') .. '/.chezmoi/dotfiles/bin/keep-mac-awake'

local function runKeepMacAwake(action, callback)
  local task = hs.task.new(keepMacAwake, function(_, stdOut, stdErr)
    local output = ((stdOut or '') .. (stdErr or '')):gsub('%s+$', '')
    callback(output)
  end, { action })

  if not (task and task:start()) then
    notify('Failed to run ' .. keepMacAwake)
  end
end

local function toggleKeepAwake()
  runKeepMacAwake('status', function(status)
    local running = status:find('is running with PID', 1, true)
    runKeepMacAwake(running and 'stop' or 'start', hs.alert.show)
  end)
end

-- Shortcuts -------------------------------------------------------------------

local shortcuts = {
  -- Modifiers, Key, Action

  -- General Shortcuts for Applications
  { hyper, 'return', launch('Ghostty') },
  { hyperCmd, 'return', launch('OpenInTerminal-Lite') },
  { hyper, 'E', launch('Finder') },
  { hyper, 'B', launch('Google Chrome') },
  { hyper, 'P', launch('Enpass') },
  { hyper, 'W', launch('WeChat') },
  { hyper, 'T', launch('RTM') },
  { hyper, 'S', launch('Spotify') },
  { hyper, 'N', launch('UpNote') },
  { hyper, 'M', launch('Mole') },
  { hyper, 'R', launch('RexBeta') },

  -- General Shortcuts for Links
  { hyper, 'G', open('https://chatgpt.com/') }, -- ChatGPT

  -- Other Shortcuts
  -- Toggle keep-mac-awake
  { hyperCmd, 'A', toggleKeepAwake },

  -- Reload Hammerspoon config
  -- NOTE: One important detail to call out here is that hs.reload() destroys the current Lua interpreter and creates a
  -- new one. Any code after hs.reload() in the same function would not be called.
  { hyperCmd, 'R', hs.reload },
}

-- Create all shortcuts
for _, s in ipairs(shortcuts) do
  hs.hotkey.bind(s[1], s[2], s[3])
end

-- Show notification after reload
hs.alert.show('Hammerspoon config loaded')

-- -- Better window switching with alt+tab
-- require('custom.alttab')"

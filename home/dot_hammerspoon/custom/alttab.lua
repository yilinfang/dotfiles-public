-- Windows-style Alt+Tab switcher (text list, no previews)
-- Hold Alt, press Tab to cycle, release Alt to switch.
-- Shift+Tab or Up goes back, Down goes forward, Esc cancels.

local M = {}

local MOD = 'alt' -- modifier to hold while pressing Tab
local SHOW_DELAY = 0.08 -- quick Alt+Tab switches without flashing the list
local ROW_H = 38
local MAX_WIDTH = 720
local PAD = 8 -- inner padding of the panel
local MARGIN = 40 -- room around the panel for its shadow
local ICON = 24
local FONT_SIZE = 14
local MAX_ROWS = 12

local fonts = hs.styledtext.defaultFonts

-- Window filter that tracks focus order (most recently used first).
-- Keep only visible standard windows (skip panels, popups and helper windows).
-- The filter caches these properties, so checking them here costs nothing at show time.
local wf =
  hs.window.filter.new():setDefaultFilter({ visible = true, allowRoles = 'AXStandardWindow' })
wf:subscribe(hs.window.filter.windowFocused, function() end)

-- windows holds entries cached at show time: { win, id, appName, title, icon }
local windows, selected, canvas, showTimer, colors = {}, 1, nil, nil, nil
local iconCache = {}

local function theme()
  local accent = { list = 'System', name = 'controlAccentColor' }
  if hs.host.interfaceStyle() == 'Dark' then
    return {
      panel = { white = 0.14, alpha = 0.97 },
      border = { white = 1, alpha = 0.12 },
      primary = { white = 0.95 },
      secondary = { white = 1, alpha = 0.5 },
      accent = accent,
    }
  end
  return {
    panel = { white = 0.98, alpha = 0.97 },
    border = { white = 0, alpha = 0.1 },
    primary = { white = 0.1 },
    secondary = { white = 0, alpha = 0.5 },
    accent = accent,
  }
end

local function appIcon(app)
  local id = app and app:bundleID()
  if not id then
    return nil
  end
  if iconCache[id] == nil then
    iconCache[id] = hs.image.imageFromAppBundle(id) or false
  end
  return iconCache[id] or nil
end

local function label(entry, isSelected, t)
  local appName, title = entry.appName, entry.title
  local para = { lineBreak = 'truncateTail' }
  local text = hs.styledtext.new(appName, {
    font = { name = fonts.boldSystem.name, size = FONT_SIZE },
    color = isSelected and { white = 1 } or t.primary,
    paragraphStyle = para,
  })
  if title ~= '' and title ~= appName then
    text = text
      .. hs.styledtext.new('   ' .. title, {
        font = { name = fonts.system.name, size = FONT_SIZE },
        color = isSelected and { white = 1, alpha = 0.8 } or t.secondary,
        paragraphStyle = para,
      })
  end
  return text
end

local function draw()
  local t = colors
  local sf = hs.screen.mainScreen():frame()
  local width = math.min(MAX_WIDTH, sf.w * 0.6)
  local n = math.min(#windows, MAX_ROWS)
  local first = math.max(1, math.min(selected - math.floor(n / 2), #windows - n + 1))
  local h = n * ROW_H + PAD * 2
  canvas:frame({
    x = sf.x + (sf.w - width) / 2 - MARGIN,
    y = sf.y + (sf.h - h) / 2 - MARGIN,
    w = width + MARGIN * 2,
    h = h + MARGIN * 2,
  })

  local els = {
    {
      type = 'rectangle',
      action = 'strokeAndFill',
      fillColor = t.panel,
      strokeColor = t.border,
      strokeWidth = 1,
      roundedRectRadii = { xRadius = 14, yRadius = 14 },
      frame = { x = MARGIN, y = MARGIN, w = width, h = h },
      withShadow = true,
      shadow = { blurRadius = 30, color = { alpha = 0.35 }, offset = { h = -8, w = 0 } },
    },
  }
  for row = 1, n do
    local i = first + row - 1
    local entry = windows[i]
    local x = MARGIN + PAD
    local y = MARGIN + PAD + (row - 1) * ROW_H
    local rowW = width - PAD * 2
    if i == selected then
      table.insert(els, {
        type = 'rectangle',
        action = 'fill',
        fillColor = t.accent,
        roundedRectRadii = { xRadius = 8, yRadius = 8 },
        frame = { x = x, y = y, w = rowW, h = ROW_H },
      })
    end
    local icon = entry.icon
    if icon then
      table.insert(els, {
        type = 'image',
        image = icon,
        imageScaling = 'scaleProportionally',
        frame = { x = x + 8, y = y + (ROW_H - ICON) / 2, w = ICON, h = ICON },
      })
    end
    local textX = x + 8 + ICON + 10
    table.insert(els, {
      type = 'text',
      text = label(entry, i == selected, t),
      frame = {
        x = textX,
        y = y + (ROW_H - FONT_SIZE * 1.3) / 2,
        w = x + rowW - textX - 10,
        h = FONT_SIZE * 1.5,
      },
    })
  end
  canvas:replaceElements(els)
end

local function hide()
  if showTimer then
    showTimer:stop()
    showTimer = nil
  end
  if canvas then
    canvas:delete()
    canvas = nil
  end
  windows = {}
end

local function show(reverse)
  -- Read window data once here so each Tab press does no Accessibility calls.
  windows = {}
  for _, win in ipairs(wf:getWindows(hs.window.filter.sortByFocusedLast)) do
    local app = win:application()
    table.insert(windows, {
      win = win,
      id = win:id(),
      appName = app and app:name() or '?',
      title = win:title() or '',
      icon = appIcon(app),
    })
  end
  if #windows == 0 then
    return
  end
  -- Like Windows: first Tab selects the previous window. If focus is on the
  -- desktop or an excluded window, entry 1 already is the previous window.
  local focused = hs.window.focusedWindow()
  local current = focused and windows[1].id == focused:id()
  selected = reverse and #windows or math.min(current and 2 or 1, #windows)
  colors = theme()
  canvas = hs.canvas.new({ x = 0, y = 0, w = 1, h = 1 })
  canvas:level(hs.canvas.windowLevels.overlay)
  draw()
  showTimer = hs.timer.doAfter(SHOW_DELAY, function()
    showTimer = nil
    if canvas then
      canvas:show(0.1)
    end
  end)
end

local function step(delta)
  selected = (selected - 1 + delta) % #windows + 1
  draw()
end

local function commit()
  local list, start = windows, selected
  hide()
  -- A window may have closed while the list was open; skip to the next live one.
  -- Use the filter's cached list: hs.window.allWindows() queries every app and is slow.
  local alive = {}
  for _, w in ipairs(wf:getWindows()) do
    alive[w:id()] = true
  end
  for k = 0, #list - 1 do
    local entry = list[(start - 1 + k) % #list + 1]
    if entry.id and alive[entry.id] then
      pcall(function()
        entry.win:focus()
      end)
      return
    end
  end
end

local types = hs.eventtap.event.types
local keys = hs.keycodes.map

local function onlyMod(f)
  local others = { 'cmd', 'alt', 'ctrl', 'fn' }
  if not f[MOD] then
    return false
  end
  for _, m in ipairs(others) do
    if m ~= MOD and f[m] then
      return false
    end
  end
  return true
end

M.tap = hs.eventtap.new({ types.keyDown, types.flagsChanged }, function(e)
  local flags = e:getFlags()
  if e:getType() == types.flagsChanged then
    if canvas and not flags[MOD] then
      commit()
    end
    return false
  end

  local key = e:getKeyCode()
  if key == keys.tab and onlyMod(flags) then
    if not canvas then
      show(flags.shift)
    else
      step(flags.shift and -1 or 1)
    end
    return true
  end

  if canvas then
    if key == keys.escape then
      hide()
    elseif key == keys.up then
      step(-1)
    elseif key == keys.down then
      step(1)
    elseif key == keys['return'] then
      commit()
    end
    return true -- swallow other keys while the switcher is open
  end
  return false
end)
M.tap:start()

return M

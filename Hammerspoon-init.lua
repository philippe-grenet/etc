-- Philippe's Hamerspoon configuration

-- Disable animations
hs.window.animationDuration=0

-- Window mamager -------------------------------------------------------------

-- Snap left or rigth
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Left", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Right", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x + (max.w / 2)
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end)

-- Move to Top Middle
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Up", function()
  local win = hs.window.focusedWindow()
  -- hs.alert.show(win)
  win:centerOnScreen()
  local f = win:frame()
  f.y = 0
  win:setFrame(f)
end)

-- Center on the screen
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Down", function()
  local win = hs.window.focusedWindow()
  win:centerOnScreen()
end)

-- Left or right screen
hs.hotkey.bind({"cmd", "alt", "ctrl"}, '1', function()
  hs.window.focusedWindow():moveOneScreenWest(true)
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, '2', function()
  hs.window.focusedWindow():moveOneScreenEast(true)
end)


-- Shortcuts to launch applications -------------------------------------------

hs.hotkey.bind({"cmd", "alt", "ctrl"}, 'D', function ()
      hs.application.launchOrFocus("Dictionary")
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, 'C', function ()
      hs.application.launchOrFocus("Calendar")
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, 'N', function ()
      hs.application.launchOrFocus("/Applications/Nexi.app")
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, 'E', function ()
      hs.application.launchOrFocus("/Applications/Emacs-mac.app")
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, 'T', function ()
      hs.application.launchOrFocus("/Applications/iTerm.app")
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, 'S', function ()
      hs.application.launchOrFocus("/Applications/Safari.app")
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, 'G', function ()
      hs.application.launchOrFocus("/Applications/Google Chrome.app")
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, 'B', function ()
      hs.application.launchOrFocus("/Library/Application Support/Citrix Receiver/Citrix Viewer.app")
end)

-- hs.hotkey.bind({"cmd", "alt", "ctrl"}, 'I', function ()
--       hs.application.launchOrFocus("/Applications/'IntelliJ IDEA CE.app'")
-- end)

function open(name)
    return function()
        hs.application.launchOrFocus(name)
        if name == 'Finder' then
            hs.appfinder.appFromName(name):activate()
        end
    end
end
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "I", open("IntelliJ IDEA CE"))



-- Bloomberg screens rotation --------------------------------------------------

-- hs.loadSpoon("ToggleScreenRotation")
-- spoon.ToggleScreenRotation:bindHotkeys( { ["BFP100-27"] = {{"cmd", "alt", "ctrl"}, "r" } } )

--[[ debug

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

hs.hotkey.bind({ "cmd", "alt", "ctrl"}, "e", function ()
      -- hs.alert.show(hs.screen.allScreens()[0]:name())
      hs.alert.show(dump(hs.screen.allScreens()))
end)

]]

-- Show that the config was reloaded
hs.alert.show("Config loaded")

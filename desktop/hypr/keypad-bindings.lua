-- Super + keypad digit selects the same workspace as the number row.
-- Use physical XKB keycodes so the shortcut works with Num Lock on or off.
local keypad_workspace_keys = { 87, 88, 89, 83, 84, 85, 79, 80, 81, 90 }
for workspace, keycode in ipairs(keypad_workspace_keys) do
  o.bind("SUPER + code:" .. keycode, "Switch to workspace " .. workspace .. " (keypad)", o.workspaces.focus(workspace))
end

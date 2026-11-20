# Desktop customizations

This branch backs up the local Omarchy display, taskbar, keypad, and Logitech setup. The [My Display plugin](../README.md) is at the repository root. The [saved monitor layout](../examples/monitors.lua) keeps the portrait output at 125% and places both landscape outputs edge-to-edge beside it.

## Restore the taskbar

Copy the two folders in `plugins/` into `~/.config/omarchy/plugins/`. They contain the custom bar and tray, including per-monitor resizing, scalable text, and the resize crash fix.

Merge the fields from `omarchy/bar-settings.json` into the existing `bar` object in `~/.config/omarchy/shell.json`. Keep the rest of that file, including the widget layout. The size settings are keyed by connector. Add `fperez.tray` to the bar if it is missing. Merge the `[bar]` and `[font]` keys in `omarchy/shell.toml` into the existing user shell TOML. Restart the shell with `omarchy restart shell`. Omarchy loads both settings files and the user plugins again when the session starts.

## Restore the monitor and keypad configuration

Merge the display rules from `examples/monitors.lua` into `~/.config/hypr/monitors.lua`. Append `hypr/keypad-bindings.lua` to `~/.config/hypr/bindings.lua` if those shortcuts are missing. Run `hyprctl reload` and check `hyprctl configerrors`.

## Restore the Logitech shortcuts

Install Solaar with `omarchy pkg add solaar` and copy or merge `solaar/rules.yaml` into `~/.config/solaar/rules.yaml`. In Solaar, set **Screen Capture**, **Dictation**, **Emoji**, **Mute Microphone**, and **Screen Lock** to **Diverted** for the MX Keys S. Copy `autostart/solaar.desktop` into `~/.config/autostart/` to start Solaar at login.

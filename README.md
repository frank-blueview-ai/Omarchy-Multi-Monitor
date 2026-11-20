# Omarchy Multi Monitor

A **My Display** bar widget for Omarchy 4.5 and Hyprland's Lua configuration. It extends Omarchy's Display plugin with controls for individual monitors.

- Match the on-screen numbers to the display selector and arrangement map. The numbers appear while the card is open and can be hidden from the card.
- Drag displays above, below, left, or right of each other. The map snaps them edge-to-edge.
- Choose landscape or portrait, and pick a resolution and refresh rate for each active display.
- Apply the highest reported resolution and the fastest refresh rate at that resolution to one or all active displays.
- Select a disabled display to re-enable it. The card protects the last active display from being disabled.

## Install

This widget uses Omarchy 4.5's Quickshell UI, its bundled display and brightness commands, and `hyprctl` with Lua monitor rules. These dependencies ship with Omarchy 4.5.

```sh
omarchy plugin add https://github.com/frank-blueview-ai/Omarchy-Multi-Monitor --enable
```

The widget appears as **My Display**. If you already have the stock **Display** widget or a local clone on the bar, remove the old widget from the bar before enabling this one. Both versions use the same Display IPC target. If your existing local plugin has the ID `fperez.monitor`, back it up before replacing it.

## Remove

```sh
omarchy plugin remove fperez.monitor
```

This removes the widget. Any monitor rules you manually saved to Hyprland's configuration can be edited separately.

## Save a layout across reloads

The card applies arrangement, orientation, mode, and enable/disable changes to the live Hyprland session. To make a layout persistent, copy the relevant rules from [the example monitor configuration](examples/monitors.lua) into your own `~/.config/hypr/monitors.lua`, adjusting connector names and positions for your setup. Find your connectors and their advertised modes with `hyprctl monitors all`.

The example captures three external displays, ordered DP-4, DP-5, DP-3 from left to right. DP-4 is portrait at 125% scale. DP-5 and DP-3 are landscape at 100%. All three use 1920×1080 at 60 Hz. Positions use scaled, rotated dimensions. The portrait screen is 864 logical pixels wide, so the middle display starts at x=864 and the right display starts at x=2784.

After saving, run `hyprctl reload` and check `hyprctl configerrors`.

Based on the [Omarchy](https://github.com/omacom/omarchy) Display plugin. See [LICENSE](LICENSE).

# Omarchy Multi Monitor

A **My Display** bar widget for Omarchy 4.5 and Hyprland's Lua configuration. It extends Omarchy's Display plugin with controls for individual monitors.

- Match the on-screen numbers to the display selector and arrangement map. The numbers appear while the card is open and can be hidden from the card.
- Drag displays above, below, left, or right of each other. The map snaps them edge-to-edge.
- Choose landscape or portrait, and pick a resolution and refresh rate for each active display.
- Apply the highest reported resolution and the fastest refresh rate at that resolution to one or all active displays.
- Select a disabled display to re-enable it. The card protects the last active display from being disabled.

## Install

From a checkout of this repository, copy the plugin into Omarchy's user plugin directory. If the directory already contains your own changes to this widget, back it up before copying.

```sh
mkdir -p ~/.config/omarchy/plugins
cp -r plugins/fperez.monitor ~/.config/omarchy/plugins/
omarchy restart shell
```

Add **My Display** to your bar through Omarchy's widget settings, or run:

```sh
omarchy bar put fperez.monitor
```

If you already have the stock **Display** widget on the bar, replace it with **My Display** in widget settings. Both versions use the same Display IPC target.

## Save a layout across reloads

The card applies arrangement, orientation, mode, and enable/disable changes to the live Hyprland session. To make a layout persistent, copy the relevant rules from [the example monitor configuration](examples/monitors.lua) into your own `~/.config/hypr/monitors.lua`, adjusting connector names and positions for your setup. Find your connectors and their advertised modes with `hyprctl monitors all`.

The example captures three external displays, ordered DP-4, DP-5, DP-3 from left to right. DP-4 is portrait at 200% scale. DP-5 and DP-3 are landscape at 100%. All three use 1920×1080 at 60 Hz. Positions use scaled, rotated dimensions.

After saving, run `hyprctl reload` and check `hyprctl configerrors`.

Based on the [Omarchy](https://github.com/omacom/omarchy) Display plugin. See [LICENSE](LICENSE).

# Hyprland Gray Theme

A gray and black Hyprland desktop setup for Arch Linux, with a Quickshell status bar, Kitty terminal, Wofi launcher, Hyprpaper wallpaper, Hyprlock lock screen, and Fish shell with Fastfetch.

[`setup-hyprland.sh`](setup-hyprland.sh) installs packages and copies the included configuration files into your home directory.

## Before you run it

**Back up your existing configuration.** The script deletes `~/.config/hypr`, replaces `~/.config/quickshell`, overwrites the Wofi stylesheet, Kitty config, and Fastfetch config, and appends settings to your Fish config. The old Quickshell directory is deleted without a backup; there is no uninstall command. Running it again replaces those configurations again.

You need:

- An existing Arch Linux installation with working networking, `pacman`, Bash, and `sudo` access.
- A normal user account. The script refuses to run as root and requests elevated privileges through `sudo`.
- The complete repository, including the `quickshell/` directory and wallpaper.
- A Hyprland build that supports the supplied `hyprland.lua` configuration and its Lua API. The installer does not check compatibility or pin package versions.
- Working graphics drivers and a way to start a Hyprland session. The script does not configure a display manager or a complete graphics/audio/network stack.

Review these machine-specific settings before installing:

- **Monitors:** [`hyprland.lua`](hyprland.lua) configures `DP-2` at `1920x1080@144` on the left and `DP-1` at `2560x1440@180` on the right. Change the outputs, modes, and positions for your displays.
- **Wallpaper:** [`hyprpaper.conf`](hyprpaper.conf) uses `/home/xay/.config/hypr/mywallpaper.png`. Replace `/home/xay` with your actual home directory; the installer copies this path unchanged.
- **Package availability:** Every package in `PACMAN_PACKAGES`, including `librewolf`, is requested through `pacman`. Check that your configured repositories provide them; the script does not fall back to the AUR for missing packages.

## Installation

Download or clone the complete repository, open a terminal in its directory, and run:

```bash
bash setup-hyprland.sh
```

Do not prefix this command with `sudo`. The script locates its source files relative to itself, so it can also be invoked using its full path.

Most package operations run without confirmation. Be ready to enter your password for `sudo`, answer Steam's package/provider prompts, and authenticate for `chsh` if asked. Select the Vulkan provider appropriate for your hardware when Steam prompts you.

After installation, fully log out and start a new Hyprland session, or reboot. This also lets the login-shell change take effect.

## What the script does

1. Enables the standard commented `[multilib]` repository block in `/etc/pacman.conf` if needed, first copying that file to `/etc/pacman.conf.bak`.
2. Runs `sudo pacman -Syu --noconfirm`, upgrading the system.
3. Installs the following packages with `pacman --needed`:

   ```text
   hyprland hyprlock hyprpaper discord code flatpak librewolf
   wofi kitty nautilus fastfetch base-devel git go ttf-hack-nerd
   pavucontrol fish
   # plus the packages listed in quickshell/packages.txt
   ```

4. Installs `steam` interactively.
5. Builds and installs `yay` from the AUR if it is missing, then installs `kew` through `yay`.
6. Adds the system-wide Flathub remote and installs Mission Center (`io.missioncenter.MissionCenter`).
7. Replaces the desktop configuration files and ensures the deployed Hyprland config includes the Kitty maximize-suppression rule.
8. Adds Fastfetch to interactive Fish startup, disables the Fish greeting, and changes your login shell to `/usr/bin/fish`.

The script stops on a failed command. Changes already made remain in place; there is no automatic rollback.

## Configuration files

| Repository source | Installed destination |
| --- | --- |
| `hyprland.lua` | `~/.config/hypr/hyprland.lua` |
| `hyprlock.conf` | `~/.config/hypr/hyprlock.conf` |
| `hyprpaper.conf` | `~/.config/hypr/hyprpaper.conf` |
| `mywallpaper.png` | `~/.config/hypr/mywallpaper.png` |
| `wofi-style.css` | `~/.config/wofi/style.css` |
| `kitty.conf` | `~/.config/kitty/kitty.conf` |
| `fastfetch.jsonc` | `~/.config/fastfetch/config.jsonc` |
| `quickshell/` | `~/.config/quickshell/` |

These are copies, not symlinks. Edit the installed files to customize your running desktop, or edit the repository files before installation. Keep your changes backed up before rerunning the installer.

Hyprland starts `hyprpaper` and the included Quickshell launcher automatically.

### Integrated Quickshell bar

The included bar is the compact monochrome version: 28 px tall, content-sized
ends with equal padding, a read-only track/artist display on the left, and a
12-hour clock in the middle. Hover the clock for CPU/GPU/RAM usage; click it
for local machine and disk stats. The right menu contains network, audio and
Bluetooth controls. Spotify-specific controls, VPN, notifications, Lights,
Night Light and a brightness slider are not included. There is no screenshot
keybinding or screenshot helper.

Colors live in [`quickshell/theme/monochrome.json`](quickshell/theme/monochrome.json).
The bar requires no separate `~/quickshell-bar` checkout. Hyprland launches
`~/.config/quickshell/run.sh -d`; the launcher prevents duplicate instances.
To restart it manually:

```bash
~/.config/quickshell/run.sh --restart -d
```

The setup script reads [`quickshell/packages.txt`](quickshell/packages.txt) for
bar and keyboard-shortcut dependencies: Quickshell, Hack Nerd Font,
NetworkManager, BlueZ, PipeWire/PipeWire-Pulse, WirePlumber, libpulse, jq,
Python, util-linux, udisks2, iproute2, gawk, grep, coreutils, procps-ng,
playerctl and brightnessctl. Qt modules are installed through Quickshell's
package dependencies. GPU drivers are unchanged. Brightnessctl is for the
existing hardware keys, not a bar slider.

The installer enables NetworkManager and Bluetooth for subsequent boots,
without restarting networking in the current session. If another network
manager is enabled, resolve that conflict before rebooting. Existing
Quickshell files are deleted and replaced directly, without backups. Other
installer behavior remains the same, including replacing `~/.config/hypr`.

The bar is adapted from [SaratAngajalaoffl/dotfiles-quickshell](https://github.com/SaratAngajalaoffl/dotfiles-quickshell/tree/1afda74e30d8d9bdb5c19f4dcd583e144d435f1b).
See [`quickshell/README.md`](quickshell/README.md) for details.

## Main keyboard shortcuts

`Super` is usually the Windows key.

| Shortcut | Action |
| --- | --- |
| `Super + Return` or `Super + T` | Open Kitty |
| `Super + D` or `Super + A` | Open Wofi |
| `Super + E` | Open Nautilus |
| `Super + Q` or `Super + Shift + Q` | Close the focused window |
| `Super + W` or `Super + Space` | Toggle floating |
| `Super + F` | Toggle fullscreen |
| `Super + Arrow` | Move focus |
| `Super + Shift + Arrow` | Move the focused window |
| `Super + 1–9, 0` | Switch to workspace 1–10 |
| `Super + Shift + 1–9, 0` | Move a window to workspace 1–10 |
| `Super + Minus` | Toggle the scratchpad |
| `Super + Shift + Minus` | Move a window to the scratchpad |
| `Super + Left/Right mouse drag` | Move/resize a floating window |
| `Super + Shift + C` | Reload Hyprland configuration |
| `Super + Shift + E` | Exit Hyprland |

The config also defines Vim-style movement keys, media keys, and brightness keys. It assigns both locking and rightward focus to `Super + L/l`; resolve that overlapping binding in `hyprland.lua` before relying on a lock shortcut. You can run `hyprlock` directly.

## Troubleshooting and limitations

- **Missing package:** If `pacman` reports a target is unavailable, resolve its repository/package source or adjust `PACMAN_PACKAGES` before rerunning. The earlier system upgrade may already have completed.
- **Wallpaper missing:** Check the absolute path in the installed `hyprpaper.conf` and confirm the wallpaper exists there.
- **Displays configured incorrectly:** Adjust the monitor blocks in the installed `hyprland.lua`. From a working Hyprland session, `hyprctl monitors` lists detected outputs.
- **Media or brightness keys do nothing:** The installer includes `pactl`, `playerctl` and `brightnessctl`. Media applications must support MPRIS; brightness keys require a kernel backlight device.
- **Incomplete stats or controls:** Network reporting expects NetworkManager, Bluetooth requires BlueZ and hardware, and audio uses PipeWire/WirePlumber. GPU utilization depends on the driver. Disk mount/eject can require a session authentication agent.
- **Bar missing:** Run `qs` from a terminal inside Hyprland to inspect its output. The included QML configuration requires compatible Quickshell modules.
- **Graphics or Steam issues:** GPU setup is outside this script's scope. Steam's provider selection does not replace configuring the appropriate graphics and Vulkan drivers for your system.

The repository contains a personal configuration; installation and runtime compatibility should be checked on your own system.

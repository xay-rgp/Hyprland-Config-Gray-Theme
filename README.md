# Hyprland Gray Theme

A gray and black Hyprland desktop setup for Arch Linux, with a Quickshell status bar, Kitty terminal, Wofi launcher, Hyprpaper wallpaper, Hyprlock lock screen, and Fish shell with Fastfetch.

[`setup-hyprland.sh`](setup-hyprland.sh) installs packages and copies the included configuration files into your home directory.

## Before you run it

**Back up your existing configuration.** The script deletes `~/.config/hypr` and `~/.config/quickshell`, overwrites the Wofi stylesheet, Kitty config, and Fastfetch config, and appends settings to your Fish config. It does not back up these files or provide an uninstall command. Running it again replaces those configurations again.

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
   quickshell pavucontrol fish
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

Hyprland starts `hyprpaper` and `qs` automatically. The Quickshell bar includes workspaces, a clock, media information, the active window title, audio and brightness controls, system statistics, and a system tray. Its colors are defined in [`quickshell/bar/DefaultTheme.qml`](quickshell/bar/DefaultTheme.qml).

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
| `Print` | Take a screenshot using `grim` |

The config also defines Vim-style movement keys, media keys, and brightness keys. It assigns both locking and rightward focus to `Super + L/l`; resolve that overlapping binding in `hyprland.lua` before relying on a lock shortcut. You can run `hyprlock` directly.

## Troubleshooting and limitations

- **Missing package:** If `pacman` reports a target is unavailable, resolve its repository/package source or adjust `PACMAN_PACKAGES` before rerunning. The earlier system upgrade may already have completed.
- **Wallpaper missing:** Check the absolute path in the installed `hyprpaper.conf` and confirm the wallpaper exists there.
- **Displays configured incorrectly:** Adjust the monitor blocks in the installed `hyprland.lua`. From a working Hyprland session, `hyprctl monitors` lists detected outputs.
- **Media, brightness, or screenshot keys do nothing:** The config calls `pactl`, `playerctl`, `brightnessctl`, and `grim`, but the installer does not explicitly install them. Ensure the commands and their required services/hardware are available.
- **Incomplete bar statistics:** Network reporting uses `nmcli`, temperature reporting uses `sensors`, and CPU/memory reporting uses `top` and `free`. These commands are not explicitly included in the install list. Network reporting expects NetworkManager; audio controls use PipeWire. Brightness and battery widgets depend on available hardware interfaces.
- **Bar missing:** Run `qs` from a terminal inside Hyprland to inspect its output. The included QML configuration requires compatible Quickshell modules.
- **Graphics or Steam issues:** GPU setup is outside this script's scope. Steam's provider selection does not replace configuring the appropriate graphics and Vulkan drivers for your system.

The repository contains a personal configuration; installation and runtime compatibility should be checked on your own system.

#!/usr/bin/env bash
# Update the grayscale desktop in a terminal, independently of Quickshell.
set -Eeuo pipefail
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/quickshell/updates"
mkdir -p -- "$state_dir"

if [[ "${1:-}" == --launch ]]; then
    # The installer replaces ~/.config/quickshell, including this script.
    # Execute a private snapshot so the update survives that replacement.
    runner=$(mktemp "$state_dir/runner-XXXXXXXX.sh")
    cp -- "${BASH_SOURCE[0]}" "$runner"
    exec kitty --hold --title 'Update desktop' bash "$runner" --run
fi
[[ "${1:-}" == --run ]] || { echo 'Usage: update-desktop.sh --launch'; exit 2; }
(( EUID != 0 )) || { echo 'Run this as your regular user, not root.'; exit 1; }
exec 9>"$state_dir/update.lock"
flock -n 9 || { echo 'A desktop update is already running.'; exit 1; }
run_dir=$(mktemp -d "$state_dir/$(date +%Y%m%d-%H%M%S)-XXXXXXXX")
exec > >(tee -a "$run_dir/update.log") 2>&1
trap 'code=$?; printf "\nUpdate stopped (exit %s). Log and any backups: %s\n" "$code" "$run_dir"; exit "$code"' ERR

repo="$HOME/Hyprland-Config-Gray-Theme"
url='https://github.com/xay-rgp/Hyprland-Config-Gray-Theme.git'
printf 'Updating desktop from %s\n\n' "$url"
if [[ ! -e "$repo" ]]; then
    git clone --branch main --single-branch "$url" "$repo"
fi
[[ -d "$repo/.git" ]] || { echo "Not a Git checkout: $repo"; exit 1; }
remote=$(git -C "$repo" remote get-url origin)
case "$remote" in
    "$url"|https://github.com/xay-rgp/Hyprland-Config-Gray-Theme|git@github.com:xay-rgp/Hyprland-Config-Gray-Theme.git) ;;
    *) echo "Unexpected origin: $remote. No installer was run."; exit 1 ;;
esac
[[ "$(git -C "$repo" branch --show-current)" == main ]] || {
    echo 'The checkout must be on main. No branches or local changes were discarded.'; exit 1;
}
echo 'Fetching the latest main branch; local changes are retained unless they conflict.'
git -C "$repo" fetch origin main
git -C "$repo" merge --ff-only FETCH_HEAD
[[ -f "$repo/setup-hyprland.sh" ]] || { echo 'setup-hyprland.sh is missing.'; exit 1; }
bash -n "$repo/setup-hyprland.sh"
git -C "$repo" rev-parse HEAD > "$run_dir/revision.txt"
git -C "$repo" status --short > "$run_dir/local-changes.txt"

# The installer deletes Hyprland and Quickshell directories before copying.
echo 'Backing up desktop configuration before installation...'
mkdir -p "$run_dir/config"
for name in hypr quickshell wofi kitty fastfetch fish gtk-4.0 btop; do
    if [[ -e "$HOME/.config/$name" || -L "$HOME/.config/$name" ]]; then
        cp -a -- "$HOME/.config/$name" "$run_dir/config/$name"
    fi
done
printf '\nBackup: %s/config\n' "$run_dir"
printf 'Running setup-hyprland.sh (system packages and desktop files).\n\n'
cd -- "$repo"
bash ./setup-hyprland.sh
printf '\nDesktop update finished successfully.\nBackup and log: %s\nLog out and back in to load the updated desktop.\n' "$run_dir"

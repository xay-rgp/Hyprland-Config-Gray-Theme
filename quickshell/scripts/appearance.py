#!/usr/bin/env python3
"""Persistent appearance and wallpaper actions for the middle bar settings."""
import argparse
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import time

ROOT = Path(__file__).resolve().parents[1]
HOME = Path.home()


def atomic(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temporary = tempfile.mkstemp(dir=path.parent, prefix='.' + path.name)
    try:
        with os.fdopen(fd, 'wb') as stream:
            stream.write(data)
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def run(args):
    return subprocess.run(args, capture_output=True, text=True, check=True, timeout=15)


def appearance(mode):
    assets = ROOT / 'theme/appearance'
    # Update the desktop preference used by GTK/libadwaita and portals.
    run(['gsettings', 'set', 'org.gnome.desktop.interface', 'color-scheme',
         'prefer-dark' if mode == 'dark' else 'prefer-light'])
    run(['gsettings', 'set', 'org.gnome.desktop.interface', 'gtk-theme',
         'Adwaita-dark' if mode == 'dark' else 'Adwaita'])
    css = HOME / '.config/gtk-4.0/gtk.css'
    backup = css.with_name('gtk.css.before-appearance-menu')
    if css.exists() and not backup.exists():
        shutil.copy2(css, backup)
    atomic(css, (assets / f'gtk-{mode}.css').read_bytes())
    atomic(ROOT / 'theme/monochrome.json', (assets / f'{mode}.json').read_bytes())


def wallpaper():
    selection = subprocess.run([
        'zenity', '--file-selection', '--title=Choose a wallpaper',
        '--filename=' + str(HOME / 'Pictures') + '/',
        '--file-filter=Images | *.png *.jpg *.jpeg *.webp *.bmp *.PNG *.JPG *.JPEG *.WEBP',
    ], capture_output=True, text=True)
    if selection.returncode == 1:
        return
    if selection.returncode != 0:
        raise RuntimeError(selection.stderr.strip() or 'Could not open the wallpaper picker')
    image = Path(selection.stdout.rstrip('\n')).resolve(strict=True)
    mime = run(['file', '--brief', '--mime-type', str(image)]).stdout.strip()
    if mime not in ('image/png', 'image/jpeg', 'image/webp', 'image/bmp', 'image/x-ms-bmp'):
        raise ValueError('Please choose a PNG, JPEG, WebP or BMP image')
    config = HOME / '.config/hypr/hyprpaper.conf'
    original = config.read_text()
    # Keep a managed copy, so moving the original picture does not break login.
    suffix = {'image/png': '.png', 'image/jpeg': '.jpg', 'image/webp': '.webp'}.get(mime, '.bmp')
    target = HOME / '.local/share/quickshell' / ('wallpaper' + suffix)
    updated, count = re.subn(r'(?m)^(\s*path\s*=)[^\n]*', lambda m: m[1] + ' ' + str(target), original)
    if count != 1:
        raise ValueError('Expected one wallpaper path in hyprpaper.conf; configuration was not changed')
    backup = config.with_name('hyprpaper.conf.before-appearance-menu')
    if not backup.exists():
        shutil.copy2(config, backup)
    atomic(target, image.read_bytes())
    atomic(config, updated.encode())
    # hyprpaper 0.8.5 no longer exposes the old hyprctl wallpaper command.
    stopped = subprocess.run(['pkill', '-u', str(os.getuid()), '-x', 'hyprpaper'], capture_output=True)
    if stopped.returncode not in (0, 1):
        raise RuntimeError('Could not stop hyprpaper to apply the wallpaper')
    for _ in range(30):
        if subprocess.run(['pgrep', '-u', str(os.getuid()), '-x', 'hyprpaper'], capture_output=True).returncode == 1:
            break
        time.sleep(0.1)
    else:
        raise RuntimeError('hyprpaper did not stop; the wallpaper is saved for next login')
    log = HOME / '.local/state/quickshell/hyprpaper.log'
    log.parent.mkdir(parents=True, exist_ok=True)
    with log.open('ab') as output:
        proc = subprocess.Popen(['hyprpaper'], stdout=output, stderr=output, start_new_session=True)
    time.sleep(0.4)
    if proc.poll() is not None:
        raise RuntimeError('hyprpaper could not start; see ' + str(log))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['light', 'dark', 'wallpaper'])
    action = parser.parse_args().action
    try:
        wallpaper() if action == 'wallpaper' else appearance(action)
    except (OSError, ValueError, RuntimeError, subprocess.SubprocessError) as error:
        message = str(error)
        print(message)
        subprocess.run(['notify-send', 'Desktop settings', message], check=False)
        return 1
    return 0


if __name__ == '__main__':
    raise SystemExit(main())

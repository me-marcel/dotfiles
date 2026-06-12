# Fedora 44 Dev Workstation Dotfiles

Reproducible Fedora 44 GNOME setup for development with:

- Orchis dark + Tela orange theme stack
- ZSH + tmux workflow
- OpenCode + VS Code setup
- Git + GNU Stow managed dotfiles

## Repository layout

- `scripts/` bootstrap and install helpers
- `stow/` stow modules (`zsh`, `tmux`, `git`, `vscode`, `opencode`, `gnome`)
- `assets/wallpapers/` wallpaper assets

## Fresh machine setup

```bash
git clone <dotfiles-repo-url> ~/.dotfiles
cd ~/.dotfiles
./scripts/bootstrap-fedora.sh --apply-stow --with-flatpak
./scripts/install-vscode.sh
./scripts/install-opencode.sh
./scripts/install-themes.sh
./scripts/install-gnome-extensions.sh
./scripts/gnome-dconf-import.sh
stow -d stow -t "$HOME" zsh tmux git vscode opencode gnome
```

## Notes

- Place your wallpaper at `assets/wallpapers/orange-sunset.jpg` before running `install-themes.sh`.
- Re-login after bootstrap so shell/theme changes fully apply.

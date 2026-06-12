# Fedora 44 Dev Workstation Dotfiles

Reproducible Fedora 44 GNOME setup for development with:

- Orchis dark + Tela orange theme stack
- ZSH + tmux workflow
- OpenCode + VS Code setup
- KeePassXC password manager
- Git + GNU Stow managed dotfiles

## Repository layout

- `scripts/` bootstrap and install helpers
- `stow/` stow modules (`zsh`, `tmux`, `git`, `vscode`, `opencode`, `gnome`)
- `assets/wallpapers/` wallpaper assets

## Fresh machine setup

```bash
git clone <dotfiles-repo-url> ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

Equivalent manual sequence is still available in the script body (`install.sh`).

`install.sh` and the helper scripts are safe to rerun; package/font/extension installers skip already-installed items where possible.

Bootstrap also ensures an SSH key exists by generating a new Ed25519 key (without passphrase) only when no existing user SSH public key is found.

## Notes

- Place your wallpaper at `assets/wallpapers/orange-sunset.jpg` before running `install-themes.sh`.
- Run `install-fonts.sh` if you want Nerd Font glyph support for icon-heavy prompts/tools.
- Re-login after bootstrap so shell/theme changes fully apply.

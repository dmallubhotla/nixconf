# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
just                  # List available commands
just install          # Test rebuild current flake (sudo nixos-rebuild test --flake .)
just test             # Validate flake (nix flake check)
just fmt              # Format code (nix fmt)
just update           # Update flake.lock (nix flake update)
just remote-update <ip> <hostname>  # Deploy to remote VM

# Standalone home-manager (without full NixOS rebuild)
home-manager switch --flake .#deepak      # CLI-only config
home-manager switch --flake .#deepak-gui  # GUI-enabled config
```

## Architecture

This is a modular NixOS flake configuration supporting WSL, VMs, and desktop hosts.

### Host Builder Pattern

`lib/default.nix` provides builder functions that compose common modules with host-specific config:

- `mkWSLHost` - WSL instances (uses `commonWSL-configuration.nix` + NixOS-WSL module)
- `mkVMHost` - QEMU/KVM VMs (uses `commonVM-configuration.nix`, includes QEMU agent, growpart, serial console options)
- `mkDesktopHost` - Physical machines (requires hardware-configuration.nix)
- `mkHomeConfiguration` - Standalone home-manager configs

All builders integrate home-manager and sops-nix automatically via `commonModules`.

### Key Files

- `hosts/hosts.nix` - Defines all host configurations using the builder functions
- `hosts/commonVM-configuration.nix` - Shared VM config (boot, networking, users, services)
- `hosts/commonWSL-configuration.nix` - Shared WSL config
- `home/deepak/home.nix` - User home-manager configuration
- `overlays/default.nix` - Custom package overlays (vim plugins, zsh plugins, MCP servers)

### Inputs Structure

- `nixpkgs-stable` (nixos-25.11) - Primary package source for hosts
- `nixpkgs` (unstable) - Available as `nixpkgs-unstable` for select packages
- `homeManager-stable` - Home-manager release-25.11
- `sops-nix` - Secrets management
- Custom flake inputs for vim plugins, MCP bundle, openclaw-image

### Adding a New Host

1. Add entry to `hosts/hosts.nix` using appropriate builder
2. For VMs: `commonVM-configuration.nix` handles most setup; add `extraModules` for host-specific config
3. For physical: Create `hardware-configuration.nix` and use `mkDesktopHost`

## Formatting

Uses treefmt-nix with: nixfmt, deadnix, shellcheck, shfmt, yamlfmt, stylua, just formatter.

## Troubleshooting

If sops-nix fails in WSL, the user systemd service may not be running:
```bash
systemctl restart user@1000
```

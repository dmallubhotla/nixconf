# executes default, set to rebuilding current flake as test
default:
    just --list

# does a nixos-rebuild test of current flake
install:
    nixos-rebuild test --flake . --sudo

# run nix flake check
test:
    nix flake check

fmt:
    nix fmt

update:
    nix flake update

# update a remote NixOS host by IP address via flake
remote-update ip hostname:
    nixos-rebuild switch --flake .#{{ hostname }} --target-host deepak@{{ ip }} --sudo --ask-sudo-password

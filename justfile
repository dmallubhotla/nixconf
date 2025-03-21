# executes default, set to rebuilding current flake as test
default:
    just --list

# does a nixos-rebuild test of current flake
install:
    sudo nixos-rebuild test --flake .

# run nix flake check
test:
    nix flake check

fmt:
    nix fmt

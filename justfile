# executes default, set to rebuilding current flake as test
default: test

# does a nixos-rebuild test of current flake
test:
    sudo nixos-rebuild test --flake .

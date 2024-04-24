
# execute default build
default: test

# builds the python module using poetry
test:
	sudo nixos-rebuild test --flake .


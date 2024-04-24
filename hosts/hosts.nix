{ lib, inputs, nixpkgs-23-11, homeManager, homeManager-23-11, NixOS-WSL, customPackageOverlay, ... }:
{
	"maxos" = lib.nixosSystem {
		system = "x86_64-linux";
		specialArgs = {
			inherit customPackageOverlay;
		};
		modules = [
			./maxos/configuration.nix
			homeManager.nixosModules.home-manager {
				home-manager.extraSpecialArgs = {
                                        withGUI = true;
                                        gitSigningKey = "976F3357369149AB";
				};
				home-manager.useGlobalPkgs = true;
				home-manager.users.deepak = {
					imports = [ ../home/deepak/home.nix ];
				};
			}
		];
	};

	"nixosWSL" = nixpkgs-23-11.lib.nixosSystem {
		system = "x86_64-linux";
		specialArgs = {
			inherit customPackageOverlay;
		};
		modules = [
			./nixosWSL/configuration.nix
			homeManager-23-11.nixosModules.home-manager {
				home-manager.extraSpecialArgs = {
                                        withGUI = false;
                                        gitSigningKey = "8F904A3FC7021497";
				};
				home-manager.useGlobalPkgs = true;
				home-manager.users.deepak = {
					imports = [ ../home/deepak/home.nix ];
				};
			}
			NixOS-WSL.nixosModules.wsl
		];
	};
}

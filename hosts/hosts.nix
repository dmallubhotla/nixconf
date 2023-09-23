{ lib, inputs, nixpkgs, mysd, homeManager, NixOS-WSL, ... }:
{
	"maxos" = lib.nixosSystem {
		system = "x86_64-linux";
		/* specialArgs = {
			inherit mysd;
		}; */
		modules = [
			./maxos/configuration.nix
			homeManager.nixosModules.home-manager {
				home-manager.extraSpecialArgs = {
					inherit mysd;
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

	"nixosWSL" = lib.nixosSystem {
		system = "x86_64-linux";
		modules = [
			./nixosWSL/configuration.nix
			homeManager.nixosModules.home-manager {
				home-manager.extraSpecialArgs = {
					inherit mysd;
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

{ lib, inputs, nixpkgs, homeManager, ... }:
{
	"maxos" = lib.nixosSystem {
		system = "x86_64-linux";
		modules = [
			./maxos/configuration.nix
			homeManager.nixosModules.home-manager {
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
				home-manager.useGlobalPkgs = true;
				home-manager.users.deepak = {
					imports = [ ../home/deepak/home_no_gui.nix ];
				};
			}
		];
	};
}
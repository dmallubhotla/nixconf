{ lib, inputs, nixpkgs-24-05, homeManager, homeManager-24-05, NixOS-WSL-2405, customPackageOverlay, ... }:
let
	linuxSystem = "x86_64-linux";
	nixpkgs-unstable = inputs.nixpkgs.legacyPackages.${linuxSystem};
in 
{
	"maxos" = lib.nixosSystem {
		system = linuxSystem;
		specialArgs = {
			inherit customPackageOverlay;
			inherit nixpkgs-unstable;
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

	"nixosWSL" = nixpkgs-24-05.lib.nixosSystem {
		system = "x86_64-linux";
		specialArgs = {
			inherit customPackageOverlay;
			inherit nixpkgs-unstable;
		};
		modules = [
			./nixosWSL/configuration.nix
			inputs.sops-nix.nixosModules.sops
			homeManager-24-05.nixosModules.home-manager {
				home-manager.extraSpecialArgs = {
					withGUI = false;
					gitSigningKey = "8F904A3FC7021497";
					inherit nixpkgs-unstable;
				};
				home-manager.useGlobalPkgs = true;
				home-manager.users.deepak = {
					imports = [ ../home/deepak/home.nix ];
				};

				home-manager.sharedModules = [
					inputs.sops-nix.homeManagerModules.sops
				];
			}

			NixOS-WSL-2405.nixosModules.wsl
		];
	};
	"nixosEggYoke" = nixpkgs-24-05.lib.nixosSystem {
		system = "x86_64-linux";
		specialArgs = {
			inherit customPackageOverlay;
			inherit nixpkgs-unstable;
		};
		modules = [
			./nixosEggYoke/configuration.nix
			inputs.sops-nix.nixosModules.sops
			homeManager-24-05.nixosModules.home-manager {
				home-manager.extraSpecialArgs = {
					withGUI = false;
					gitSigningKey = "47831B15427F5A55";
					inherit nixpkgs-unstable;
				};
				home-manager.useGlobalPkgs = true;
				home-manager.users.deepak = {
					imports = [ ../home/deepak/home.nix ];
				};
				home-manager.sharedModules = [
					inputs.sops-nix.homeManagerModules.sops
				];
			}
			NixOS-WSL-2405.nixosModules.wsl
		];
	};
}

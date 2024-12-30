{ lib, inputs, nixpkgs-23-11, nixpkgs-24-05, homeManager, homeManager-23-11, homeManager-24-05, NixOS-WSL, NixOS-WSL-2405, customPackageOverlay, ... }:
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
        "nixosEggYoke" = nixpkgs-24-05.lib.nixosSystem {
                system = "x86_64-linux";
                specialArgs = {
                        inherit customPackageOverlay;
                };
                modules = [
                        ./nixosEggYoke/configuration.nix
                        homeManager-24-05.nixosModules.home-manager {
                                home-manager.extraSpecialArgs = {
                                        withGUI = false;
                                        gitSigningKey = "47831B15427F5A55";
                                };
                                home-manager.useGlobalPkgs = true;
                                home-manager.users.deepak = {
                                        imports = [ ../home/deepak/home.nix ];
                                };
                        }
                        NixOS-WSL-2405.nixosModules.wsl
                ];
        };
}

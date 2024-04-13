{
	description = "Configuration v1";

	inputs = {
			nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

			nixpkgs-23-11.url = "github:NixOS/nixpkgs/nixos-23.11";
			homeManager = {
				url = "github:nix-community/home-manager";
				inputs.nixpkgs.follows = "nixpkgs";
			};

                        homeManager-23-11 = {
				url = "github:nix-community/home-manager/release-23.11";
				inputs.nixpkgs.follows = "nixpkgs-23-11";
			};

			NixOS-WSL = {
			  url = "github:nix-community/NixOS-WSL";
			  inputs.nixpkgs.follows = "nixpkgs";
			};
		};

	outputs = { self, nixpkgs, homeManager, NixOS-WSL, nixpkgs-23-11, homeManager-23-11, ...}@inputs: {

		nixosConfigurations = (
			import ./hosts/hosts.nix {
				inherit nixpkgs;
				inherit homeManager;
				inherit inputs;
				inherit (nixpkgs) lib;
				inherit NixOS-WSL;
                                inherit nixpkgs-23-11;
                                inherit homeManager-23-11;
			}
		);

	};
}

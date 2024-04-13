{
	description = "Configuration v1";

	inputs = {
			nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

			homeManager = {
				url = "github:nix-community/home-manager";
				inputs.nixpkgs.follows = "nixpkgs";
			};

			NixOS-WSL = {
			  url = "github:nix-community/NixOS-WSL";
			  inputs.nixpkgs.follows = "nixpkgs";
			};
		};

	outputs = { self, nixpkgs, homeManager, NixOS-WSL, ...}@inputs: {

		nixosConfigurations = (
			import ./hosts/hosts.nix {
				inherit nixpkgs;
				inherit homeManager;
				inherit inputs;
				inherit (nixpkgs) lib;
				inherit NixOS-WSL;
			}
		);

	};
}

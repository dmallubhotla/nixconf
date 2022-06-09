{
	description = "Configuration v1";

	inputs = {
			nixpkgs.url = "github:NixOS/nixpkgs/release-22.05";

			homeManager = {
					url = "github:nix-community/home-manager";
					inputs.nixpkgs.follows = "nixpkgs";
				};
		};

	outputs = { self, nixpkgs, homeManager, ...}@inputs: {

		nixosConfigurations = (
			import ./hosts/hosts.nix {
				inherit nixpkgs;
				inherit homeManager;
				inherit inputs;
				inherit (nixpkgs) lib;
			}
		);

	};
}

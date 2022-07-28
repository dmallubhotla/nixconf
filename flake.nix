{
	description = "Configuration v1";

	inputs = {
			nixpkgs.url = "github:NixOS/nixpkgs";

			homeManager = {
				url = "github:nix-community/home-manager";
				inputs.nixpkgs.follows = "nixpkgs";
			};

			mysd = {
				url = "git+ssh://git@gitea.deepak.science:2222/deepak/sd.git";
				flake = false;
			};
		};

	outputs = { self, nixpkgs, homeManager, mysd, ...}@inputs: {

		nixosConfigurations = (
			import ./hosts/hosts.nix {
				inherit nixpkgs;
				inherit homeManager;
				inherit inputs;
				inherit mysd;
				inherit (nixpkgs) lib;
			}
		);

	};
}

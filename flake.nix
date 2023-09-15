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
			NixOS-WSL = {
			  url = "github:nix-community/NixOS-WSL";
			  inputs.nixpkgs.follows = "nixpkgs";
			};
		};

	outputs = { self, nixpkgs, homeManager, mysd, NixOS-WSL, ...}@inputs: {

		nixosConfigurations = (
			import ./hosts/hosts.nix {
				inherit nixpkgs;
				inherit homeManager;
				inherit inputs;
				inherit mysd;
				inherit (nixpkgs) lib;
				inherit NixOS-WSL;
			}
		);

	};
}

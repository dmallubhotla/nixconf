{
  description = "Configuration v1";

  inputs = {
    nixpkgs.url = "flake:nixpkgs";
    homeManager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, homeManager, ...}: {

    nixosConfigurations."maxos" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        homeManager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.users.deepak = {
            imports = [ ./home.nix ];
          };
        }
      ];
    };

  };
}

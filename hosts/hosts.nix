{
  inputs,
  customPackageOverlay,
# ...
}:
let
  linuxSystem = "x86_64-linux";
  lib = inputs.nixpkgs.lib;
  nixpkgs-unstable = import inputs.nixpkgs {
    system = linuxSystem;
    config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "claude-code"
      ];
  };
in
{
  "maxos" = inputs.nixpkgs-24-11.lib.nixosSystem {
    system = linuxSystem;
    specialArgs = {
      inherit customPackageOverlay;
      inherit nixpkgs-unstable;
      withDocker = false;
    };
    modules = [
      ./maxos/configuration.nix
      inputs.sops-nix.nixosModules.sops
      inputs.homeManager-24-11.nixosModules.home-manager
      {
        home-manager.extraSpecialArgs = {
          withGUI = true;
          gitSigningKey = "976F3357369149AB";
          rundirnum = "1000";
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
    ];
  };
  "nixosWalrus" = inputs.nixpkgs-24-11.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit customPackageOverlay;
      inherit nixpkgs-unstable;
      hostname = "nixosWalrus";
      stateVersion = "24.11";
      withDocker = false;
    };
    modules = [
      (
        { ... }:
        {
          nix.registry.nixpkgs.flake = inputs.nixpkgs-24-11;
        }
      )
      ./commonWSL-configuration.nix
      inputs.sops-nix.nixosModules.sops
      inputs.homeManager-24-11.nixosModules.home-manager
      {
        home-manager.extraSpecialArgs = {
          withGUI = false;
          gitSigningKey = "8F904A3FC7021497";
          obsidian_dir = "/mnt/d/applications/obsidian/vault01";
          inherit nixpkgs-unstable;
        };
        home-manager.useGlobalPkgs = true;
        home-manager.users.deepak = {
          imports = [
            ../home/deepak/home.nix
          ];
        };
        home-manager.sharedModules = [
          inputs.sops-nix.homeManagerModules.sops
        ];
      }

      inputs.NixOS-WSL-2411.nixosModules.wsl
    ];
  };
  "nixosEggYoke" = inputs.nixpkgs-24-11.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit customPackageOverlay;
      inherit nixpkgs-unstable;
      hostname = "nixosEggYoke";
      stateVersion = "22.05";
      withDocker = true;
    };
    modules = [
      (
        { ... }:
        {
          nix.registry.nixpkgs.flake = inputs.nixpkgs-24-11;
        }
      )
      ./commonWSL-configuration.nix
      inputs.sops-nix.nixosModules.sops
      inputs.homeManager-24-11.nixosModules.home-manager
      {
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
      inputs.NixOS-WSL-2411.nixosModules.wsl
    ];
  };
}

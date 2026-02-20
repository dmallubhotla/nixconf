# Lib functions for host creation
{
  inputs,
  customPackageOverlay,
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

  # Common modules shared across all host types
  commonModules = [
    inputs.sops-nix.nixosModules.sops
    inputs.homeManager-stable.nixosModules.home-manager
  ];

  # Pin nixpkgs registry to stable
  pinRegistry =
    { ... }:
    {
      nix.registry.nixpkgs.flake = inputs.nixpkgs-stable;
    };

  # Default home-manager setup for a user
  mkHomeManagerConfig =
    {
      username,
      homeModule,
      withGUI ? false,
      gitSigningKey ? null,
      obsidian_dir ? null,
      win_home_dir ? null,
      extraSpecialArgs ? { },
    }:
    {
      home-manager = {
        useGlobalPkgs = true;
        extraSpecialArgs = {
          inherit
            withGUI
            gitSigningKey
            nixpkgs-unstable
            obsidian_dir
            win_home_dir
            ;
        }
        // extraSpecialArgs;
        users.${username} = {
          imports = [ homeModule ];
        };
        sharedModules = [
          inputs.sops-nix.homeManagerModules.sops
        ];
      };
    };

  # Base host configuration builder
  mkHost =
    {
      hostname,
      system ? linuxSystem,
      stateVersion,
      modules,
      specialArgs ? { },
    }:
    inputs.nixpkgs-stable.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit
          inputs
          customPackageOverlay
          nixpkgs-unstable
          hostname
          stateVersion
          ;
      }
      // specialArgs;
      modules = [
        pinRegistry
      ]
      ++ commonModules
      ++ modules;
    };

  # WSL-specific host builder
  mkWSLHost =
    {
      hostname,
      stateVersion,
      withDocker ? true,
      withGUI ? false,
      gitSigningKey,
      obsidian_dir ? null,
      win_home_dir ? null,
      extraModules ? [ ],
      extraSpecialArgs ? { },
    }:
    mkHost {
      inherit hostname stateVersion;
      specialArgs = {
        inherit withDocker;
      }
      // extraSpecialArgs;
      modules = [
        ../hosts/commonWSL-configuration.nix
        (mkHomeManagerConfig {
          username = "deepak";
          homeModule = ../home/deepak/home.nix;
          inherit
            withGUI
            gitSigningKey
            obsidian_dir
            win_home_dir
            ;
        })
        inputs.NixOS-WSL-stable.nixosModules.wsl
      ]
      ++ extraModules;
    };

  # VM-specific host builder with QEMU agent and VM niceties
  mkVMHost =
    {
      hostname,
      stateVersion,
      withDocker ? false,
      withGUI ? false,
      gitSigningKey,
      # VM-specific options
      withQemuAgent ? true,
      withCloudInit ? false,
      withGrowpart ? true,
      withSerialConsole ? true,
      extraModules ? [ ],
      extraSpecialArgs ? { },
    }:
    mkHost {
      inherit hostname stateVersion;
      specialArgs = {
        inherit
          withDocker
          withQemuAgent
          withCloudInit
          withGrowpart
          withSerialConsole
          ;
      }
      // extraSpecialArgs;
      modules = [
        ../hosts/commonVM-configuration.nix
        (mkHomeManagerConfig {
          username = "deepak";
          homeModule = ../home/deepak/home.nix;
          inherit withGUI gitSigningKey;
        })
      ]
      ++ extraModules;
    };

  # Desktop/physical host builder
  mkDesktopHost =
    {
      hostname,
      stateVersion,
      hardwareConfig,
      withDocker ? true,
      withGUI ? true,
      gitSigningKey,
      extraModules ? [ ],
      extraSpecialArgs ? { },
    }:
    mkHost {
      inherit hostname stateVersion;
      specialArgs = {
        inherit withDocker;
      }
      // extraSpecialArgs;
      modules = [
        hardwareConfig
        (mkHomeManagerConfig {
          username = "deepak";
          homeModule = ../home/deepak/home.nix;
          inherit withGUI gitSigningKey;
        })
      ]
      ++ extraModules;
    };

  # Standalone home-manager configuration builder (for flake outputs)
  # Usage: home-manager switch --flake .#username
  mkHomeConfiguration =
    {
      username,
      homeModule,
      system ? linuxSystem,
      withGUI ? false,
      gitSigningKey ? null,
      obsidian_dir ? null,
      win_home_dir ? null,
      extraSpecialArgs ? { },
    }:
    let
      # Allow unfree packages like Discord, Obsidian for GUI configs
      unfreePackages = [
        "claude-code"
        "discord"
        "obsidian"
      ];
      pkgs = import inputs.nixpkgs-stable {
        inherit system;
        overlays = [ customPackageOverlay ];
        config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) unfreePackages;
      };
      pkgs-unstable = import inputs.nixpkgs {
        inherit system;
        overlays = [ customPackageOverlay ];
        config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) unfreePackages;
      };
    in
    inputs.homeManager-stable.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
        inherit
          withGUI
          username
          gitSigningKey
          obsidian_dir
          win_home_dir
          ;
        nixpkgs-unstable = pkgs-unstable;
      }
      // extraSpecialArgs;
      modules = [
        homeModule
        inputs.sops-nix.homeManagerModules.sops
      ];
    };

in
{
  inherit
    mkHost
    mkWSLHost
    mkVMHost
    mkDesktopHost
    mkHomeConfiguration
    nixpkgs-unstable
    ;
}

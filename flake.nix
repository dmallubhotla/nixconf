{
  description = "Configuration v1";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    NixOS-WSL-stable = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    homeManager-stable = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # Custom Vim Plugins
    cmp-vimtex = {
      url = "github:micangl/cmp-vimtex/master";
      flake = false;
    };
    spaceport-nvim = {
      url = "github:CWood-sdf/spaceport.nvim/main";
      flake = false;
    };

    # parrot-nvim = {
    #   url = "github:frankroeder/parrot.nvim/main";
    #   flake = false;
    # };

    nomodoro = {
      url = "github:dbinagi/nomodoro/main";
      flake = false;
    };

    nvim-web-devicons = {
      url = "github:nvim-tree/nvim-web-devicons/master";
      flake = false;
    };

    zsh-completions = {
      url = "github:zsh-users/zsh-completions/master";
      flake = false;
    };

    claude-mcp-bundle = {
      url = "git+ssh://git@github.com/dmallubhotla/claude_mcp_bundle";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mdt = {
      url = "github:basilioss/mdt/main";
      flake = false;
    };

    openclaw-image = {
      url = "git+ssh://git@github.com/dmallubhotla/openclaw-image";
    };

    proxmox-nixos = {
      url = "github:SaumonNet/proxmox-nixos";
      # Note: proxmox-nixos uses nixpkgs-stable internally; we let it use its
      # own pinned nixpkgs to avoid ABI mismatches in the Proxmox packages.
    };

  };

  outputs =
    {
      self,
      systems,
      nixpkgs,
      cmp-vimtex,
      spaceport-nvim,
      nomodoro,
      ...
    }@inputs:
    let
      customPackageOverlay =
        (import ./overlays/default.nix {
          inherit cmp-vimtex;
          inherit spaceport-nvim;
          inherit inputs;
          inherit nomodoro;
          # parrot-nvim = inputs.parrot-nvim;
        }).overlay;
      # Small tool to iterate over each systems
      eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});

      # Eval the treefmt modules from ./treefmt.nix
      treefmtEval = eachSystem (pkgs: inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
      # Import our lib for host and home creation
      myLib = import ./lib {
        inherit inputs customPackageOverlay;
      };
    in
    {
      nixosConfigurations = import ./hosts/hosts.nix {
        inherit inputs customPackageOverlay;
      };

      # Bootable installer ISOs for bare-metal hosts.
      # Build with: nix build .#packages.x86_64-linux.shannon-iso
      # Flash with: dd if=result/iso/nixos-*.iso of=/dev/sdX bs=4M status=progress
      #
      # The ISO boots a standard NixOS installer. After booting:
      #   1. Partition disks and mount under /mnt
      #   2. nixos-generate-config --root /mnt
      #   3. Replace hosts/<hostname>/hardware-configuration.nix
      #   4. nixos-install --flake /path/to/nixconf#<hostname>
      packages.x86_64-linux.shannon-iso =
        let
          isoSystem = inputs.nixpkgs-stable.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {
              inherit inputs customPackageOverlay;
            };
            modules = [
              # Standard NixOS installer base
              "${inputs.nixpkgs-stable}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
              # Include useful hardware support for Dell PowerEdge
              "${inputs.nixpkgs-stable}/nixos/modules/profiles/all-hardware.nix"
              (
                { pkgs, lib, ... }:
                {
                  # Include git and nix so you can fetch + apply the flake during install
                  environment.systemPackages = with pkgs; [
                    git
                    vim
                    parted
                    gptfdisk
                    ipmitool # iDRAC/IPMI management
                    smartmontools
                    pciutils
                  ];

                  # Add proxmox-nixos binary cache so install is fast
                  nix.settings = {
                    substituters = [
                      "https://cache.nixos.org"
                      "https://cache.saumon.network/proxmox-nixos"
                    ];
                    trusted-public-keys = [
                      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                      "proxmox-nixos:D9RYSWpQQC/msZUWphOY2I5RLH5Dd6yQcaHIuug7dWM="
                    ];
                    experimental-features = [ "nix-command" "flakes" ];
                  };

                  # Enable SSH in installer for remote access (e.g. via iDRAC console)
                  services.openssh = {
                    enable = true;
                    settings.PermitRootLogin = "yes";
                  };

                  users.users.root.initialPassword = "nixos"; # change immediately after install
                }
              )
            ];
          };
        in
        isoSystem.config.system.build.isoImage;

      # Standalone home-manager configurations
      # Usage: home-manager switch --flake .#deepak
      # Or: home-manager switch --flake .#deepak-gui
      homeConfigurations = {
        # CLI-only configuration (for servers/VMs/WSL)
        "deepak" = myLib.mkHomeConfiguration {
          username = "deepak";
          homeModule = ./home/deepak/home.nix;
          withGUI = false;
          gitSigningKey = "8F904A3FC7021497";
        };

        # GUI-enabled configuration (for desktops)
        "deepak-gui" = myLib.mkHomeConfiguration {
          username = "deepak";
          homeModule = ./home/deepak/home.nix;
          withGUI = true;
          gitSigningKey = "8F904A3FC7021497";
        };
      };

      formatter = eachSystem (pkgs: treefmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.wrapper);

      # for `nix flake check`
      checks = eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.check self;
      });

      devShells = eachSystem (pkgs: {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            kubernetes-helm
            kubectl
            jq
            stern
            nixfmt
            alejandra
          ];
        };
      });
    };
}

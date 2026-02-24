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

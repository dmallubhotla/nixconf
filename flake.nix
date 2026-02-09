{
  description = "Configuration v1";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";

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
      url = "github:nix-community/home-manager/release-25.05";
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
      url = "git+ssh://git@gitea.deepak.science:2222/deepak/claude_mcp_bundle.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mdt = {
      url = "github:basilioss/mdt/main";
      flake = false;
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
    in
    {
      nixosConfigurations = (
        import ./hosts/hosts.nix {
          inherit inputs;
          inherit customPackageOverlay;
        }
      );

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

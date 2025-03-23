{

  description = "Configuration v1";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-24-11.url = "github:NixOS/nixpkgs/nixos-24.11";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    sops-nix.url = "github:Mic92/sops-nix";

    NixOS-WSL-2411 = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs-24-11";
    };

    homeManager-24-11 = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs-24-11";
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

    parrot-nvim = {
      url = "github:frankroeder/parrot.nvim/main";
      flake = false;
    };

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
          parrot-nvim = inputs.parrot-nvim;
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

      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
      # for `nix flake check`
      checks = eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check self;
      });

    };
}

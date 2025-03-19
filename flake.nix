{

  description = "Configuration v1";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    treefmt-nix.url = "github:numtide/treefmt-nix";

    sops-nix.url = "github:Mic92/sops-nix";

    nixpkgs-24-05.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-24-11.url = "github:NixOS/nixpkgs/nixos-24.11";

    # only use this for Maxos, prefer specifying version explicitly
    homeManager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    homeManager-24-05 = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-24-05";
    };

    NixOS-WSL-2411 = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs-24-11";
    };

    homeManager-24-11 = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs-24-11";
    };

    NixOS-WSL-2405 = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs-24-05";
    };

    NixOS-WSL = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
      homeManager,
      NixOS-WSL,
      NixOS-WSL-2405,
      nixpkgs-24-05,
      homeManager-24-05,
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
          inherit nixpkgs;
          inherit homeManager;
          inherit inputs;
          inherit (nixpkgs) lib;
          inherit NixOS-WSL;
          inherit NixOS-WSL-2405;
          inherit nixpkgs-24-05;
          inherit homeManager-24-05;
          inherit cmp-vimtex;
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

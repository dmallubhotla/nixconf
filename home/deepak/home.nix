{ pkgs, config, specialArgs, lib, ...}:

let
  obsidian = lib.throwIf (lib.versionOlder "1.5.3" pkgs.obsidian.version) "Obsidian no longer requires EOL Electron" (
    pkgs.obsidian.override {
      electron = pkgs.electron_25.overrideAttrs (_: {
        preFixup = "patchelf --add-needed ${pkgs.libglvnd}/lib/libEGL.so.1 $out/bin/electron"; # NixOS/nixpkgs#272912
        meta.knownVulnerabilities = [ ]; # NixOS/nixpkgs#273611
      });
    }
  );
in
{

  programs.home-manager.enable = true;
  home.packages = [
    pkgs.hello
    (pkgs.writeScriptBin "nixFlakes" ''
      exec ${pkgs.nixUnstable}/bin/nix --experimental-features "nix-command flakes" "$@"
    '')
    pkgs.cachix
    pkgs.kubectl
    pkgs.bat
    pkgs.eza
    pkgs.fd
    pkgs.ripgrep
    pkgs.just

    # lsps
    pkgs.nil
  ] ++ pkgs.lib.optionals specialArgs.withGUI [
    pkgs.discord
    obsidian
    pkgs.audacity
    pkgs.nextcloud-client
  ];

  home.homeDirectory = "/home/deepak";
  home.username = "deepak";

  # required, was previously default
  home.stateVersion = "18.09";

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  services.nextcloud-client = pkgs.lib.mkIf specialArgs.withGUI {
    enable = true;
  };

  programs.git = {
    enable = true;
    userName  = "Deepak Mallubhotla";
    userEmail = "dmallubhotla+github@gmail.com";
    signing = {
      key = specialArgs.gitSigningKey;
      signByDefault = true;
    };
    extraConfig = {
      core = {
        fileMode = false;
      };
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [ vimtex 
      vim-nix
      # plenary and stuff for telescope
      plenary-nvim telescope-nvim telescope-file-browser-nvim
      ctrlp-vim
      # lsp stuff
      nvim-lspconfig
      wiki-vim
      vim-markdown
    ];
    extraConfig = ''
      inoremap jj <Esc>
      inoremap kk <Esc>
      lua << EOF
      require'lspconfig'.nil_ls.setup{}
      ${builtins.readFile ./neovim/wiki-vim.lua}

      EOF
    '';
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      doo="./do.sh";
      wttr="curl wttr.in";
    };
    history = {
      size = 10000;
      path = "${lib.removePrefix "/home/deepak/" config.xdg.dataHome}/zsh/history";
    };
    oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "poetry"
          "themes"
          "emoji-clock"
          "screen"
          "ssh-agent"
        ];
        theme = "random";
    };
    plugins = [
      {
        name = "sd";
        src = pkgs.fetchFromGitHub {
          owner = "ianthehenry";
          repo = "sd";
          rev = "ecd1ab8d3fc3a829d8abfb8bf1e3722c9c99407b";
          sha256 = "0fm1r8w73vaab5r9dj5jdxsfc7pbddxf4dvvasfq8rry2dxaf7sy";
        };
      }
      {
        name = "zsh-z";
        src = pkgs.fetchFromGitHub {
          owner = "agkozak";
          repo = "zsh-z";
          rev = "b5e61d03a42a84e9690de12915a006b6745c2a5f";
          sha256 = "1gsgmsvl1sl9m3yfapx6bp0y15py8610kywh56bgsjf9wxkrc3nl";
        };
      }
    ];
    initExtra = ''
      eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
    '';
  };


}

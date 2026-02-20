{
  pkgs,
  config,
  lib,
  # These come from extraSpecialArgs (works in both NixOS module and standalone mode)
  nixpkgs-unstable,
  withGUI ? false,
  withSops ? true,
  gitSigningKey ? null,
  obsidian_dir ? null,
  win_home_dir ? null,
  ...
}:
let
  pkgs-unstable = nixpkgs-unstable;
in
lib.mkMerge (
  [
    {
      programs.home-manager.enable = true;
      home.packages = [
        pkgs.hello
        # (pkgs.writeScriptBin "nixFlakes" ''
        # 	exec ${pkgs.nixVersions.git}/bin/nix --experimental-features "nix-command flakes" "$@"
        # '')
        pkgs.nix-search-cli
        pkgs.cachix
        pkgs.attic-client
        pkgs.kubectl
        pkgs.bat
        pkgs.eza
        pkgs.fd
        pkgs.ripgrep
        pkgs.just
        pkgs.chafa
        pkgs.fontpreview
        pkgs.poppler-utils
        pkgs.tdf
        pkgs.viu
        pkgs.jq

        pkgs-unstable.tea
        pkgs-unstable.gh

        pkgs.wego
        # cli markdown tool
        pkgs.glow

        # lsps
        # pkgs.nil
        pkgs.nixd
        pkgs.pyright
        pkgs.terraform-ls

        pkgs.fzf
        pkgs.sops
        pkgs.age
        pkgs.ydiff
        pkgs.xsel
        pkgs.delta
        pkgs.uair

        pkgs-unstable.claude-code
        # default_python
        # pkgs-unstable.uv
        # pkgs-unstable.nodejs

        # From our claude bundle
        pkgs.custom-servers.arxiv-mcp-server
        pkgs.custom-servers.basic-memory-server
        pkgs.custom-servers.mcp-text-editor
      ]
      ++ pkgs.lib.optionals withGUI [
        pkgs.discord
        pkgs.obsidian
        pkgs.audacity
        pkgs.nextcloud-client
        pkgs.libreoffice-qt6-fresh
      ];

      home.homeDirectory = "/home/deepak";
      home.username = "deepak";

      # Update from 18.09 to fix pure flake evaluation issues
      # See: https://github.com/nix-community/home-manager/issues/1981
      home.stateVersion = "24.11";

      home.sessionPath = [
        "$HOME/.local/bin"
      ];

      home.sessionVariables =
        let
          # Use provided values or defaults
          win_home = if win_home_dir != null then win_home_dir else "/mnt/c/Users/Deepak";
          obsidian = if obsidian_dir != null then obsidian_dir else "/mnt/c/Users/Deepak/Documents/vault01";
        in
        {
          # Namespace our own nixconf variables with DPK

          # Set a common directory for Windows for WSL installs
          # Different per host
          DPK_WIN_HOME_DIR = win_home;
          DPK_OBSIDIAN_DIR = obsidian;

          # UV_PYTHON = "${default_python}";
        };

      programs.direnv.enable = true;
      programs.direnv.nix-direnv.enable = true;

      xdg.enable = true;
      xdg.configFile."uair".source = ./config/uair;

      services.nextcloud-client = pkgs.lib.mkIf withGUI {
        enable = true;
      };

      programs.git = {
        enable = true;
        signing = lib.mkIf (gitSigningKey != null) {
          key = gitSigningKey;
          signByDefault = true;
        };
        settings = {
          user = {
            name = "Deepak Mallubhotla";
            email = "dmallubhotla+github@gmail.com";
          };
          core = {
            fileMode = false;
          };
          init = {
            defaultBranch = "master";
          };
          # git config --global --add url."git@github.com:".insteadOf "https://github.com/"
          url = {
            "git@github.com".insteadOf = "https://github.com";
          };
        };
        includes = [
          # this allows us to have a local gitconfig maybe?
          { path = "~/.gitconfig.local"; }
        ];
      };

      programs.neovim = {
        enable = true;
        package = pkgs-unstable.neovim-unwrapped;
        defaultEditor = true;
        vimAlias = true;

        plugins = with pkgs-unstable.vimPlugins; [
          {
            plugin = vimtex;
            config = "let g:nix_recommended_style = 0";
          }
          vim-nix
          # plenary and stuff for telescope
          plenary-nvim
          telescope-nvim
          nvim-treesitter
          telescope-fzf-native-nvim
          telescope-file-browser-nvim
          telescope-media-files-nvim
          telescope-symbols-nvim

          fzf-lua
          # ctrlp-vim

          # lsp stuff

          nvim-cmp
          cmp-nvim-lsp
          cmp_luasnip
          nvim-lspconfig
          friendly-snippets
          luasnip

          guess-indent-nvim

          vim-tmux-navigator
          # vim-vinegar
          oil-nvim

          wiki-vim
          # apparently these plugins can coexist
          render-markdown-nvim
          vim-markdown
          cmp-buffer
          # vim-airline
          vim-fugitive
          flash-nvim
          gitsigns-nvim
          which-key-nvim

          overseer-nvim

          # prettiness
          lualine-nvim
          goyo-vim
          limelight-vim
          nui-nvim
          zen-mode-nvim
          twilight-nvim

          # color schemes
          rose-pine
          kanagawa-nvim
          nightfox-nvim

          # custom plugins from flakes
          pkgs.customVimPlugins.cmp-vimtex
          # pkgs.customVimPlugins.spaceport-nvim
          pkgs.customVimPlugins.nomodoro
          # pkgs.customVimPlugins.parrot-nvim
          pkgs.customVimPlugins.nvim-web-devicons

          # syntax highlighting
          vim-just
        ];
        extraConfig = import ./neovim/init-vim.nix { inherit config; };
      };

      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
      };

      programs.zsh = {
        enable = true;
        shellAliases = {
          doo = "./do.sh";
          wttr = "curl wttr.in";
          gcd = "_t=$(git rev-parse --show-toplevel) && cd \"$_t\" && pwd";
        };
        history = {
          size = 10000;
          path = "${config.xdg.dataHome}/zsh/history";
        };
        oh-my-zsh = {
          enable = true;
          plugins = [
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
          pkgs.customZshPlugins.zsh-completions
        ];
        initContent = ''
          eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
        '';
      };

      programs.tmux = import ./tmux/tmux.nix {
        inherit config;
        inherit pkgs;
        inherit pkgs-unstable;
      };

      systemd.user.services.cacheweather = {
        Unit = {
          Description = "cache weather data";
        };
        Service = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "cache-weather-script" ''
            set -euxo pipefail
            # PATH=$PATH:${lib.makeBinPath [ pkgs.wego ]}
            ${pkgs.wego}/bin/wego --help
            ${pkgs.wego}/bin/wego -f json > ${config.xdg.cacheHome}/weather/weather-cache.json
            ${pkgs.jq}/bin/jq -r '. | {location: .Location, current_tempc: .Current.TempC, current_tempf: ((1.8 * .Current.TempC + 32) |round), desc: .Current.Desc} | "\(.location): \(.current_tempf) F \(.desc)"' ~/.cache/weather/weather-cache.json > ${config.xdg.cacheHome}/weather/short-weather.txt
          '';
        };
      };

      systemd.user.timers.cacheweather = {
        Unit = {
          Description = "cache weather data";
        };
        Timer = {
          Unit = "cacheweather.service";
          AccuracySec = "5s";
          OnCalendar = "*:0/15";
        };
        Install = {
          WantedBy = [ "timers.target" ];
        };
      };

      systemd.user.services = {
        uair = {
          Unit = {
            Description = "Uair pomodoro timer";
          };
          Service = {
            Type = "simple";
            ExecStart = "${pkgs.uair}/bin/uair -q";
            Restart = "always";
          };
          Install = {
            WantedBy = [ "default.target" ];
          };
        };
      };
    }
  ]
  ++ lib.optionals withSops [
    {
      sops = {
        age.keyFile = "/home/deepak/.config/sops/age/keys.txt";
        defaultSopsFile = ./secrets.yaml;
        secrets = {
          anthropic_api_key = { };
          hello = { };
          newkey = { };
        };
      };
    }
  ]
)

{
  pkgs,
  config,
  specialArgs,
  lib,
  ...
}:
let
  pkgs-unstable = specialArgs.nixpkgs-unstable;
in
# default_python = pkgs-unstable.python313;
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
    pkgs.poppler_utils
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

    pkgs.thefuck
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
  ++ pkgs.lib.optionals specialArgs.withGUI [
    pkgs.discord
    pkgs.obsidian
    pkgs.audacity
    pkgs.nextcloud-client
    pkgs.libreoffice-qt6-fresh
  ];

  home.homeDirectory = "/home/deepak";
  home.username = "deepak";

  # required, was previously default
  home.stateVersion = "18.09";

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  home.sessionVariables =
    let
      win_home_dir = specialArgs.win_home_dir or "/mnt/c/Users/Deepak";
      obsidian_dir = specialArgs.obsidian_dir or "/mnt/c/Users/Deepak/Documents/vault01";
    in
    {
      # Namespace our own nixconf variables with DPK

      # Set a common directory for Windows for WSL installs
      #
      # Different per host
      #
      DPK_WIN_HOME_DIR = "${win_home_dir}";
      DPK_OBSIDIAN_DIR = "${obsidian_dir}";

      # UV_PYTHON = "${default_python}";
    };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  xdg.enable = true;
  xdg.configFile."uair".source = ./config/uair;

  services.nextcloud-client = pkgs.lib.mkIf specialArgs.withGUI {
    enable = true;
  };

  programs.git = {
    enable = true;
    userName = "Deepak Mallubhotla";
    userEmail = "dmallubhotla+github@gmail.com";
    signing = {
      key = specialArgs.gitSigningKey;
      signByDefault = true;
    };
    extraConfig = {
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

  programs.thefuck.enable = true;

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
      path = "${lib.removePrefix "/home/deepak/" config.xdg.dataHome}/zsh/history";
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

  programs.newsboat = {
    enable = true;
    extraConfig = ''
      urls-source "freshrss"
      freshrss-url "https://freshrss.deepak.science/api/greader.php"
      freshrss-login "deepak"
      freshrss-passwordfile "${config.sops.secrets.freshrssapikey.path}"


      ## ## ## ## ## ## ##
      ## ## Stolen from https://forums.freebsd.org/threads/newsboat-rss-reader-enable-vim-key-bindings.69448/
      ## ##
      ## ## Disabling the browser but could consider using w3m?
      ## ##
      ## ## ## ## ## ## ##
      # general settings
      auto-reload yes
      max-items 50

      # externel browser
      # browser "/usr/local/bin/w3m %u"
      # macro m set browser "/usr/local/bin/mpv %u"; open-in-browser ; set browser "/usr/local/bin/w3m %u"
      # macro l set browser "/usr/local/bin/firefox %u"; open-in-browser ; set browser "/usr/local/bin/w3m %u"

      # unbind keys
      # unbind-key ENTER
      unbind-key j
      unbind-key k
      unbind-key J
      unbind-key K

      # bind keys - vim style
      bind-key j down
      bind-key k up
      # bind-key l open
      # bind-key h quit

      # solarized
      color background         default   default
      color listnormal         default   default
      color listnormal_unread  default   default
      color listfocus          black     cyan
      color listfocus_unread   black     cyan
      color info               default   black
      color article            default   default

      # highlights
      highlight article "^(Title):.*$" blue default
      highlight article "https?://[^ ]+" red default
      highlight article "\\[image\\ [0-9]+\\]" green default
    '';
  };

  sops = {
    age.keyFile = "/home/deepak/.config/sops/age/keys.txt"; # must have no password!
    # It's also possible to use a ssh key, but only when it has no password:
    #age.sshKeyPaths = [ "/home/user/path-to-ssh-key" ];
    defaultSopsFile = ./secrets.yaml;

    secrets = {
      anthropic_api_key = {
        path = "${config.sops.defaultSymlinkPath}/anthropic_api_key";
      };
      hello = { };
      newkey = { };
      freshrssapikey = { };
    };
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

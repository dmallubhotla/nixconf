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
  home.packages =
    [
      pkgs.hello
      # (pkgs.writeScriptBin "nixFlakes" ''
      # 	exec ${pkgs.nixVersions.git}/bin/nix --experimental-features "nix-command flakes" "$@"
      # '')
      pkgs.cachix
      pkgs.attic-client
      pkgs.kubectl
      pkgs.bat
      pkgs.eza
      pkgs.fd
      pkgs.ripgrep
      pkgs.just
      pkgs.chafa
      pkgs.tdf
      pkgs.viu

      # cli markdown tool
      pkgs.glow

      # lsps
      pkgs.nil
      # pkgs.nodePackages.pyright
      # pkgs.pyright

      pkgs.thefuck
      pkgs.fzf
      pkgs.sops
      pkgs.age
      pkgs.ydiff
      pkgs.xsel
      pkgs.delta

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
    in
    {
      # Namespace our own nixconf variables with DPK

      # Set a common directory for Windows for WSL installs
      #
      # Different per host
      #
      DPK_WIN_HOME_DIR = "${win_home_dir}";
      DPK_OBSIDIAN_DIR = "/mnt/c/Users/Deepak/Documents/vault01";

      # UV_PYTHON = "${default_python}";
    };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  xdg.enable = true;

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

    plugins = with pkgs.vimPlugins; [
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
      # need fzf for parrot
      fzf-lua
      ctrlp-vim
      # lsp stuff
      lsp-zero-nvim
      nvim-cmp
      cmp-nvim-lsp
      cmp_luasnip
      nvim-lspconfig

      vim-tmux-navigator
      # vim-vinegar
      oil-nvim

      wiki-vim
      vim-markdown
      cmp-buffer
      # vim-airline
      vim-fugitive
      flash-nvim
      gitsigns-nvim
      friendly-snippets
      luasnip
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
      pkgs.customVimPlugins.parrot-nvim
      pkgs.customVimPlugins.nvim-web-devicons

      # syntax highlighting
      vim-just
    ];
    extraConfig = import ./neovim/init-vim.nix { inherit config; };
  };

  programs.thefuck.enable = true;

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
    initExtra = ''
      eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
    '';
  };

  programs.tmux = {
    enable = true;
    historyLimit = 100000;
    clock24 = true;
    keyMode = "vi";
    mouse = true;
    prefix = "M-,";
    plugins = [
      pkgs.tmuxPlugins.vim-tmux-navigator
      pkgs.tmuxPlugins.better-mouse-mode
      pkgs.tmuxPlugins.sensible
      # pkgs.tmuxPlugins.tmux-powerline

      pkgs.tmuxPlugins.power-theme
    ];
    extraConfig = ''
      set-option -g status-position top
      unbind '"'
      unbind %
      set -s copy-command 'xsel -bi'
      bind -N "Change layout"  -T prefix % next-layout
      bind -N "Horizontal split"  -T prefix | split-window -h
      bind -N "Vertical split"    -T prefix - split-window -v
      bind -N "Enter copy mode"   -T prefix Space copy-mode
      bind -N "Load buffer from xsel and paste" -T prefix C-p run "xsel -ob | tmux load-buffer - ; tmux paste-buffer"
      set -g escape-time 1
      bind -N "Leave copy mode" -T copy-mode-vi Escape send-keys -X cancel
      bind -N "Leave copy mode" -T copy-mode-vi y      send -X copy-pipe
      bind -N "Selection toggle" -T copy-mode-vi Space  if -F "#{selection_present}" { send -X clear-selection } { send -X begin-selection }
      bind -N "Copy and leave copy-mode" -T copy-mode-vi Enter  send -X copy-pipe-and-cancel
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
    };
  };
}

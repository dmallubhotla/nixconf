{ pkgs, config, specialArgs, lib, ...}:

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
    pkgs.obsidian
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
    includes = [
      # this allows us to have a local gitconfig maybe?
      { path = "~/.gitconfig.local"; }
    ];
  };


  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      vimtex
      vim-nix
      # plenary and stuff for telescope
      plenary-nvim telescope-nvim telescope-file-browser-nvim
      ctrlp-vim
      # lsp stuff
      lsp-zero-nvim
      nvim-cmp
      cmp-nvim-lsp
      cmp_luasnip
      nvim-lspconfig
      wiki-vim
      vim-markdown
      cmp-buffer
      vim-airline
      vim-fugitive
      friendly-snippets
      luasnip
    ];
    extraConfig = ''
      inoremap jj <Esc>
      inoremap kk <Esc>
      lua << EOF

      local lsp_zero = require('lsp-zero')
      lsp_zero.on_attach(function(client, bufnr)
        lsp_zero.default_keymaps({buffer = bufnr})
      end)

      local cmp = require('cmp')
      local cmp_format = lsp_zero.cmp_format({details = true})
      local cmp_action = lsp_zero.cmp_action()

      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        sources = {
          {name = 'nvim_lsp'},
          {name = 'buffer'},
          {name = 'luasnip'},
        },
        formatting = cmp_format,
        mapping = cmp.mapping.preset.insert({
          -- ['<Tab>'] = cmp_action.tab_complete(),
          -- ['<S-Tab>'] = cmp_action.select_prev_or_fallback(),
          ['<Tab>'] = cmp_action.luasnip_supertab(),
          ['<S-Tab>'] = cmp_action.luasnip_shift_supertab(),
          ['<C-f>'] = cmp_action.luasnip_jump_forward(),
          ['<C-b>'] = cmp_action.luasnip_jump_backward(),
          ['<CR>'] = cmp.mapping.confirm({select = false}),
        }),
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        }
      })
      require'lspconfig'.nil_ls.setup{}

      vim.g.vim_markdown_folding_level = 2
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

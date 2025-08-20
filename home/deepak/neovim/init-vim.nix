{ ... }:
# ^ passing in config for things as needed but we don't use it currently
''
  inoremap jj <Esc>
  inoremap kk <Esc>

  lua << EOF

  vim.opt.tabstop = 4
  vim.opt.shiftwidth = 4
  vim.opt.expandtab = false
  vim.opt.list = true
  vim.opt.listchars = { eol = "¬", tab = "▸┈" , trail = '·', multispace = '·' }

  vim.opt.foldlevelstart = 99

  vim.opt.number = true
  vim.opt.relativenumber = true

  vim.opt.ignorecase = true
  vim.opt.smartcase = true

  -- scary hopefully secure in neovim
  vim.opt.exrc = true

  vim.opt.spell = true
  vim.opt.spelllang = 'en_gb'

  vim.keymap.set("n", "<leader>N", "R<Enter><Esc>")
  vim.g.python_recommended_style = 0
  -- ctrlp setup
  vim.g.ctrlp_custom_ignore = {
  	file = '\\v\\.(aux|bbl|blg|bcf|fdb_latexmk|fls|run.xml|tdo|toc|log|pdf)$'
  }

  require('gitsigns').setup()
  require("oil").setup({
    use_default_keymaps = false,
    keymaps = {
      ["g?"] = { "actions.show_help", mode = "n" },
      ["<CR>"] = "actions.select",
      ["<C-->"] = { "actions.select", opts = { vertical = true } },
      ["<C-|>"] = { "actions.select", opts = { horizontal = true } },
      ["<C-t>"] = { "actions.select", opts = { tab = true } },
      ["<C-r>"] = "actions.preview",
      ["<C-c>"] = { "actions.close", mode = "n" },
      ["<C-l>"] = "actions.refresh",
      ["-"] = { "actions.parent", mode = "n" },
      ["_"] = { "actions.open_cwd", mode = "n" },
      ["`"] = { "actions.cd", mode = "n" },
      ["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
      ["gs"] = { "actions.change_sort", mode = "n" },
      ["gx"] = "actions.open_external",
      ["g."] = { "actions.toggle_hidden", mode = "n" },
      ["g\\"] = { "actions.toggle_trash", mode = "n" },
    },
    view_options = {
      show_hidden = true,
    },
  })
  vim.api.nvim_set_keymap("n", "<leader>oi", "<cmd>lua require('oil').open_float()<CR>", { noremap = true})

  -- require("nvim-web-devicons").setup({})

  -- load file browser and telescope
  ${builtins.readFile ./telescope.lua}

  -- $ --{builtins.readFile ./spaceport.lua}

  -- color scheme
  require("rose-pine").setup({})
  require("kanagawa").setup({})
  require("nightfox").setup({})
  vim.cmd("colorscheme kanagawa-dragon")

  vim.keymap.set('n', "<leader>zm", '<cmd>ZenMode<CR>', { noremap = true, desc = "Toggle zen-mode" })

  require('flash').setup()
  vim.keymap.set('n', "<leader>ft", function() require("flash").toggle() end, {desc = "Toggle flash.nvim search", noremap = true})

  vim.keymap.set('n', "<leader>tf", '<cmd>FzfLua<CR>', {desc = "Toggle flash.nvim search", noremap = true})

  require('guess-indent').setup {}
  require('which-key').setup({})
  ${builtins.readFile ./lsp.lua}
  vim.keymap.set('n', "]d", vim.diagnostic.goto_next, { noremap = true, desc = "Next diagnostic" })
  vim.keymap.set('n', "[d", vim.diagnostic.goto_prev, { noremap = true, desc = "Previous diagnostic" })
  vim.keymap.set('n', "<leader>d", vim.diagnostic.open_float, { noremap = true, desc = "Open diagnostic" })
  vim.g.vim_markdown_folding_level = 2
  vim.g.vim_markdown_math = 1
  vim.g.vim_markdown_frontmatter = 1
  vim.g.vim_markdown_strikethrough = 1
  vim.g.vim_markdown_edit_url_in = 'vsplit'
  ${builtins.readFile ./wiki-vim.lua}

  vim.g.vimtex_fold_enabled = true

  ${builtins.readFile ./overseer.lua}

  require("nomodoro").setup({
  	work_time = 10,
  	short_break_time = 2,
  	long_break_time = 5,
  	break_cycle=5,
  })
  vim.api.nvim_set_keymap("n", "<leader>nw", "<cmd>NomoWork<CR>", { noremap = true})
  vim.api.nvim_set_keymap("n", "<leader>nb", "<cmd>NomoBreak<CR>", { noremap = true})
  vim.api.nvim_set_keymap("n", "<leader>ns", "<cmd>NomoStop<CR>", { noremap = true})
  vim.api.nvim_set_keymap("n", "<leader>nm", "<cmd>NomoMenu<CR>", { noremap = true})

  ${builtins.readFile ./lualine.lua}

  ${builtins.readFile ./toggle-checkbox.lua}
  EOF
''

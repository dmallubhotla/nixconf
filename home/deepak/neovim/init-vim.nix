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

vim.opt.spell = true
vim.opt.spelllang = 'en_gb'

vim.keymap.set("n", "<leader>N", "R<Enter><Esc>")

-- ctrlp setup
vim.g.ctrlp_custom_ignore = {
	file = '\\v\\.(aux|bbl|blg|bcf|fdb_latexmk|fls|run.xml|tdo|toc|log|pdf)$'
}

${builtins.readFile ./spaceport.lua}
require('gitsigns').setup()

-- color scheme
require("rose-pine").setup({})
require("kanagawa").setup({})
vim.cmd("colorscheme kanagawa-dragon")

vim.keymap.set('n', "<leader>zm", '<cmd>ZenMode<CR>', { noremap = true, desc = "Toggle zen-mode" })

require('flash').setup()

require('which-key').setup({})
${builtins.readFile ./lsp.lua}
vim.keymap.set('n', "]d", vim.diagnostic.goto_next, { noremap = true, desc = "Next diagnostic" })
vim.keymap.set('n', "[d", vim.diagnostic.goto_prev, { noremap = true, desc = "Previous diagnostic" })
vim.keymap.set('n', "<leader>d", vim.diagnostic.open_float, { noremap = true, desc = "Open diagnostic" })
vim.g.vim_markdown_folding_level = 2
${builtins.readFile ./wiki-vim.lua}

vim.g.vimtex_fold_enabled = true

require("overseer").setup()
-- set keymap for commands
vim.api.nvim_set_keymap('n', '<leader>oo', '<cmd>OverseerToggle<CR>', { noremap = true})
vim.api.nvim_set_keymap('n', '<leader>or', '<cmd>OverseerRun<CR>', { noremap = true})

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

EOF
''

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

vim.keymap.set("n", "<leader>n", "R<Enter><Esc>")

-- ctrlp setup
vim.g.ctrlp_custom_ignore = {
	file = '\\v\\.(aux|bbl|blg|bcf|fdb_latexmk|fls|run.xml|tdo|toc|log|pdf)$'
}

${builtins.readFile ./spaceport.lua}
require('gitsigns').setup()

-- color scheme
require("rose-pine").setup({})
require("kanagawa").setup({})
vim.cmd("colorscheme rose-pine")

require('flash').setup()

require('which-key').setup({})
${builtins.readFile ./lsp.lua}
vim.g.vim_markdown_folding_level = 2
${builtins.readFile ./wiki-vim.lua}

vim.g.vimtex_fold_enabled = true

require("overseer").setup()
-- set keymap for commands
vim.api.nvim_set_keymap('n', '<leader>oo', '<cmd>OverseerToggle<CR>', { noremap = true})
vim.api.nvim_set_keymap('n', '<leader>or', '<cmd>OverseerRun<CR>', { noremap = true})

EOF
''

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

require("nomodoro").setup({})
vim.api.nvim_set_keymap("n", "<leader>nw", "<cmd>NomoWork<CR>", { noremap = true})
vim.api.nvim_set_keymap("n", "<leader>nb", "<cmd>NomoBreak<CR>", { noremap = true})
vim.api.nvim_set_keymap("n", "<leader>ns", "<cmd>NomoStop<CR>", { noremap = true})

-- put this at the end in case it depends on other things being configured
require('lualine').setup({
	extensions = {"fugitive", "overseer"},
	sections = {
		lualine_c = {
			"filename",
			{
				"overseer",
				icons_enabled = false,
			},
			require("nomodoro").status
		},
		lualine_x = {
			"encoding", {"fileformat", icons_enabled = false}, "filetype"
		}
	}
})

EOF
''

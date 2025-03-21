require("telescope").setup {
  extensions = {
    file_browser = {
      -- disables netrw and use telescope-file-browser in its place
      hijack_netrw = true,
    },
  },
}

require("telescope").load_extension "file_browser"
require('telescope').load_extension('fzf')

vim.api.nvim_set_keymap("n", "<leader>tt", "<cmd>Telescope<CR>", {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>tg", "<cmd>Telescope live_grep<CR>", {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>to", "<cmd>Telescope find_files<CR>", {noremap = true})
vim.api.nvim_set_keymap("n", "<leader>tb", "<cmd>Telescope file_browser<CR>", {noremap = true}) 


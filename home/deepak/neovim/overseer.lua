require("overseer").setup({
	task_list = {
		-- Default detail level for tasks. Can be 1-3.
		default_detail = 1,
		direction = "left",

		-- Set keymap to false to remove default behavior
		-- You can add custom keymaps here as well (anything vim.keymap.set accepts)
		bindings = {
			["?"] = "ShowHelp",
			["g?"] = "ShowHelp",
			["<CR>"] = "RunAction",
			["<C-e>"] = "Edit",
			["o"] = "Open",
			["<C-v>"] = "OpenVsplit",
			["<C-s>"] = "OpenSplit",
			["<C-f>"] = "OpenFloat",
			["<C-q>"] = "OpenQuickFix",
			["p"] = "TogglePreview",
			["<C-l>"] = "IncreaseDetail",
			["<C-h>"] = "DecreaseDetail",
			["L"] = "IncreaseAllDetail",
			["H"] = "DecreaseAllDetail",
			["["] = "DecreaseWidth",
			["]"] = "IncreaseWidth",
			["{"] = "PrevTask",
			["}"] = "NextTask",
			["<C-k>"] = "ScrollOutputUp",
			["<C-j>"] = "ScrollOutputDown",
			["q"] = "Close",
		},
	},
})
-- set keymap for commands
vim.api.nvim_set_keymap("n", "<leader>oo", "<cmd>OverseerToggle<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>or", "<cmd>OverseerRun<CR>", { noremap = true })

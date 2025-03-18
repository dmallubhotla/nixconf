-- spaceport
-- Require and setup.
-- attempting to create a custom screen for current directory.

local getCwd = function()
	local cwd = vim.fn.getcwd()
	return {
		dir = cwd,
		isDir = require("spaceport.data").isdir(cwd),
	}
end
local cwdProject = {
	lines = {
		-- Don't need to display anything, enough to just include so it ends up in the remaps.
	},
	topBuffer = 0,
	title = nil,
	remaps = {
		{
			key = ".",
			description = "Open cwd immediately",
			mode = "n",
			action = function()
				require("spaceport.data").cd(getCwd())
			end,
		},
	},
}

require("spaceport").setup({
	sections = {
		"_global_remaps",
		"name_blue_green",
		"remaps",
		cwdProject,
		"recents",
	},
})
-- TODO do I really actually use the telescope spaceport extensions?
require("telescope").load_extension("spaceport")
-- spaceport breaks a bit if whitespace visible
-- set up autocmd to set and unset vim.opt.list as needed
vim.api.nvim_create_autocmd("User", {
	pattern = "SpaceportEnter",
	callback = function(ev)
		vim.opt.list = false
	end,
})
vim.api.nvim_create_autocmd("User", {
	pattern = "SpaceportDone",
	callback = function(ev)
		vim.opt.list = true
	end,
})

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
			"encoding",
			{"fileformat", icons_enabled = false},
			"filetype"
		}
	}
})


-- put this at the end in case it depends on other things being configured
--

local function parrot_status()
	local status_info = require("parrot.config").get_status_info()
	local status = ""
	if status_info.is_chat then
		status = status_info.prov.chat.name
	else
		status = status_info.prov.command.name
	end
	return string.format("%s(%s)", status, status_info.model)
end

require("lualine").setup({
	options = {
		globalstatus = true,
		ignore_focus = { "vimtex-toc" },
	},
	extensions = { "fugitive", "overseer" },
	sections = {
		lualine_c = {
			"filename",
			{
				"overseer",
				icons_enabled = false,
			},
			require("nomodoro").status,
			-- parrot_status,
		},
		lualine_x = {
			"encoding",
			{ "fileformat", icons_enabled = false },
			"filetype",
		},
	},
})

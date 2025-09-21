-- local lsp_zero = require("lsp-zero")
-- lsp_zero.on_attach(function(client, bufnr)
-- 	lsp_zero.default_keymaps({ buffer = bufnr })
-- end)

local cmp = require("cmp")
local luasnip = require("luasnip")
-- local cmp_format = lsp_zero.cmp_format({ details = true })
-- local cmp_action = lsp_zero.cmp_action()

require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
	sources = {
		{ name = "nvim_lsp" },
		{
			name = "buffer",
			option = {
				get_bufnrs = function()
					return vim.api.nvim_list_bufs()
				end,
			},
		},
		{ name = "luasnip", option = { show_autosnippets = true } },
		-- { name = "luasnip" },
		{ name = "vimtex" },
	},
	formatting = cmp_format,
	mapping = cmp.mapping.preset.insert({
		["<CR>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				if luasnip.expandable() then
					luasnip.expand()
				else
					cmp.confirm({
						select = true,
					})
				end
			else
				fallback()
			end
		end),

		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.locally_jumpable(1) then
				luasnip.jump(1)
			else
				fallback()
			end
		end, { "i", "s" }),

		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.locally_jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	}),
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
})
vim.lsp.enable("pyright")
vim.lsp.enable("nixd")
vim.lsp.enable("terraformls")

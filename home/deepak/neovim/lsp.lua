local lsp_zero = require("lsp-zero")
lsp_zero.on_attach(function(client, bufnr)
	lsp_zero.default_keymaps({ buffer = bufnr })
end)

local cmp = require("cmp")
local cmp_format = lsp_zero.cmp_format({ details = true })
local cmp_action = lsp_zero.cmp_action()

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
		{ name = 'luasnip', option = { show_autosnippets = true } },
		-- { name = "luasnip" },
		{ name = "vimtex" },
	},
	formatting = cmp_format,
	mapping = cmp.mapping.preset.insert({
		-- ['<Tab>'] = cmp_action.tab_complete(),
		-- ['<S-Tab>'] = cmp_action.select_prev_or_fallback(),
		["<Tab>"] = cmp_action.luasnip_supertab(),
		["<S-Tab>"] = cmp_action.luasnip_shift_supertab(),
		["<C-f>"] = cmp_action.luasnip_jump_forward(),
		["<C-b>"] = cmp_action.luasnip_jump_backward(),
		["<CR>"] = cmp.mapping.confirm({ select = false }),
	}),
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
})
-- require("lspconfig").nil_ls.setup({})
require("lspconfig").pyright.setup({})
require("lspconfig").nixd.setup({})

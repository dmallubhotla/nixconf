{ config }:
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

  -- scary hopefully secure in neovim
  vim.opt.exrc = true

  vim.opt.spell = true
  vim.opt.spelllang = 'en_gb'

  vim.keymap.set("n", "<leader>N", "R<Enter><Esc>")
  vim.g.python_recommended_style = 0
  -- ctrlp setup
  vim.g.ctrlp_custom_ignore = {
  	file = '\\v\\.(aux|bbl|blg|bcf|fdb_latexmk|fls|run.xml|tdo|toc|log|pdf)$'
  }

  require('gitsigns').setup()
  require("oil").setup({
    use_default_keymaps = false,
    keymaps = {
      ["g?"] = { "actions.show_help", mode = "n" },
      ["<CR>"] = "actions.select",
      ["<C-->"] = { "actions.select", opts = { vertical = true } },
      ["<C-|>"] = { "actions.select", opts = { horizontal = true } },
      ["<C-t>"] = { "actions.select", opts = { tab = true } },
      ["<C-r>"] = "actions.preview",
      ["<C-c>"] = { "actions.close", mode = "n" },
      ["<C-l>"] = "actions.refresh",
      ["-"] = { "actions.parent", mode = "n" },
      ["_"] = { "actions.open_cwd", mode = "n" },
      ["`"] = { "actions.cd", mode = "n" },
      ["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
      ["gs"] = { "actions.change_sort", mode = "n" },
      ["gx"] = "actions.open_external",
      ["g."] = { "actions.toggle_hidden", mode = "n" },
      ["g\\"] = { "actions.toggle_trash", mode = "n" },
    },
    view_options = {
      show_hidden = true,
    },
  })
  vim.api.nvim_set_keymap("n", "<leader>oi", "<cmd>lua require('oil').open_float()<CR>", { noremap = true})

  -- require("nvim-web-devicons").setup({})

  -- load file browser and telescope
  ${builtins.readFile ./telescope.lua}

  -- $ --{builtins.readFile ./spaceport.lua}

  -- color scheme
  require("rose-pine").setup({})
  require("kanagawa").setup({})
  require("nightfox").setup({})
  vim.cmd("colorscheme kanagawa-dragon")

  vim.keymap.set('n', "<leader>zm", '<cmd>ZenMode<CR>', { noremap = true, desc = "Toggle zen-mode" })

  require('flash').setup()
  vim.keymap.set('n', "<leader>ft", function() require("flash").toggle() end, {desc = "Toggle flash.nvim search", noremap = true})

  require('which-key').setup({})
  ${builtins.readFile ./lsp.lua}
  vim.keymap.set('n', "]d", vim.diagnostic.goto_next, { noremap = true, desc = "Next diagnostic" })
  vim.keymap.set('n', "[d", vim.diagnostic.goto_prev, { noremap = true, desc = "Previous diagnostic" })
  vim.keymap.set('n', "<leader>d", vim.diagnostic.open_float, { noremap = true, desc = "Open diagnostic" })
  vim.g.vim_markdown_folding_level = 2
  vim.g.vim_markdown_math = 1
  vim.g.vim_markdown_frontmatter = 1
  vim.g.vim_markdown_strikethrough = 1
  vim.g.vim_markdown_edit_url_in = 'vsplit'
  ${builtins.readFile ./wiki-vim.lua}

  vim.g.vimtex_fold_enabled = true

  ${builtins.readFile ./overseer.lua}
  require("parrot").setup({
  	providers = {
  		anthropic = {
  			api_key = { "cat", "${config.sops.secrets.anthropic_api_key.path}" },
  		},
  	},
  	hooks = {
  		Complete = function(prt, params)
  			local template = [[
  			I have the following code from {{filename}}:

  			```{{filetype}}
  			{{selection}}
  			```

  			Please finish the code above carefully and logically.
  			Respond just with the snippet of code that should be inserted."
  			]]
  			local model_obj = prt.get_model "command"
  			prt.Prompt(params, prt.ui.Target.append, model_obj, nil, template)
  		end,
  		CompleteFullContext = function(prt, params)
  			local template = [[
  			I have the following code from {{filename}}:

  			```{{filetype}}
  			{{filecontent}}
  			```

  			Please look at the following section specifically:
  			```{{filetype}}
  			{{selection}}
  			```

  			Please finish the code above carefully and logically.
  			Respond just with the snippet of code that should be inserted.
  			]]
  			local model_obj = prt.get_model "command"
  			prt.Prompt(params, prt.ui.Target.append, model_obj, nil, template)
  		end,
  		CompleteMultiContext = function(prt, params)
  			local template = [[
  			I have the following code from {{filename}} and other realted files:

  			```{{filetype}}
  			{{multifilecontent}}
  			```

  			Please look at the following section specifically:
  			```{{filetype}}
  			{{selection}}
  			```

  			Please finish the code above carefully and logically.
  			Respond just with the snippet of code that should be inserted.
  			]]
  			local model_obj = prt.get_model "command"
  			prt.Prompt(params, prt.ui.Target.append, model_obj, nil, template)
  		end,
  		Explain = function(prt, params)
  			local template = [[
  			Your task is to take the code snippet from {{filename}} and explain it with gradually increasing complexity.
  			Break down the code's functionality, purpose, and key components.
  			The goal is to help the reader understand what the code does and how it works.

  			```{{filetype}}
  			{{selection}}
  			```

  			Use the markdown format with codeblocks and inline code.
  			Explanation of the code above:
  			]]
  			local model = prt.get_model "command"
  			prt.logger.info("Explaining selection with model: " .. model.name)
  			prt.Prompt(params, prt.ui.Target.new, model, nil, template)
  		end,
  		ProofReader = function(prt, params)
  			local chat_prompt = [[
  			I want you to act as a proofreader. I will provide you with texts and
  			I would like you to review them for any spelling, grammar, or
  			punctuation errors. Once you have finished reviewing the text,
  			provide me with any necessary corrections or suggestions to improve the
  			text. Highlight the corrected fragments (if any) using markdown backticks.

  			When you have done that subsequently provide me with a slightly better
  			version of the text, but keep close to the original text.

  			Finally provide me with an ideal version of the text.

  			For each of these versions, you can elide sections which include long unchanged text with NO_CHANGES_HERE.

  			Whenever I provide you with text, you reply in this format directly:


  			## Summary of suggestions:

  			{a brief list of spelling, grammar and punctuation errors, with brief snippets of the original text so I can search and find each change, followed by summaries of what types of changes are in the slightly better and ideal versions}

  			## Corrected text:

  			{corrected text, or say "NO_CORRECTIONS_NEEDED" instead if there are no corrections made}

  			## Slightly better text

  			{slightly better text}

  			## Ideal text

  			{ideal text}
  			]]
  			prt.ChatNew(params, chat_prompt)
  		end,
  		ProofReader2 = function(prt, params)
  			local chat_prompt = [[
  			I want you to act as a professional proofreader and editor. When I provide you with text, please:

  			1. First, identify and correct errors in
  			  - spelling
  			  - grammar
  			  - punctuation
  			  - syntax errors.
  			  - Technical accuracy (for domain-specific content especially)
  			Mark corrections using markdown backticks.

  			2. Second, analyze stylistic elements including
  			  - clarity
  			  - conciseness
  			  - word choice
  			  - sentence structure
  			  - paragraph organization and transitions (as appropriate for text length)

  			3. Provide your response in this structured format:

  			# Summary of the text:
  				Provide a concise overview of the text (1-2 sentences).
  				For longer texts (5+ paragraphs), include a brief outline of the content.


  			## Summary of suggestions:
  			- List specific errors found with brief context
  			- Group similar issues together
  			- Note patterns if they exist
  			- Highlight 3-5 most impactful improvements
  			- Summarize the types of improvements made in each version

  			## Corrected text:
  			Present the text with technical errors fixed (or state "NO_CORRECTIONS_NEEDED" if appropriate)

  			## Enhanced text:
  			Provide a version with moderate improvements to readability and flow while preserving the original voice and style. You may use [NO_CHANGES_HERE] to indicate substantial unchanged sections to keep your response more concise.

  			## Optimal text:
  			Present an ideal version that maintains the original intent but optimizes for clarity, impact, and professional quality. Use [NO_CHANGES_HERE] as mentioned above.

  			Please maintain the original meaning and tone while making your suggestions. If you're uncertain about the author's intent in any section, note this and provide alternative interpretations.
  			For very long texts, focus on the most impactful improvements.
  			]]
  			prt.ChatNew(params, chat_prompt)

  		end,
  	},
  })

  vim.api.nvim_set_keymap("n", "<leader>pt", "<cmd>PrtChatToggle<CR>", { noremap = true})

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

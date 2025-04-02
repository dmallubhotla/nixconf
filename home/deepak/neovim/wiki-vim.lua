-- vim.g.wiki_root = "/home/deepak/wiki"
vim.g.wiki_root = vim.env.DPK_OBSIDIAN_DIR
vim.g.wiki_journal = {
	name = "100-daily",
	date_format = {
		daily = "%Y/%m/%Y-%m-%d",
		weekly = "%Y/week_%V",
		monthly = "%Y/%m/summary.md",
	},
}

vim.g.wiki_select_method = {
	-- pages = require("wiki.ui_select").pages,
	pages = "wiki#fzf#pages",
	tags = require("wiki.ui_select").tags,
	-- 	toc = require("wiki.ui_select").toc,
	-- 	links = require("wiki.ui_select").links,
}

local function find_wiki_path_for_file(filename)
	-- recursively search for the file name in the wiki_root using ripgrep
	local rg_result_pipe = assert(io.popen(string.format("rg -g '%s' --files \"%s\"", filename, vim.g.wiki_root)))
	local rg_result = rg_result_pipe:read("*line")
	rg_result_pipe:close()

	-- if ripgrep found a result, return that
	if rg_result then
		return rg_result
	end

	-- if it didn't find a result, the file does not exist;
	-- in that case, the link will point to the (not yet existing)
	-- corresponding file in the wiki_root
	if vim.g.wiki_root:sub(-1) == "/" then
		return vim.g.wiki_root .. filename
	else
		return vim.g.wiki_root .. "/" .. filename
	end
end

local function resolve_wiki_link(url)
	local components = {}

	-- print(vim.inspect(url))

	for element in (url.stripped .. "#"):gmatch("([^#]*)#") do
		table.insert(components, element)
	end

	-- print(vim.inspect(components))
	-- print("spot A")

	local filename = components[1]
	url.anchor = components[2] or ""

	-- print("spot B")

	-- infer the .md file extension
	if filename:sub(-3) ~= ".md" then
		filename = filename .. ".md"
	end

	-- print("spot C")
	-- print(filename)
	if (url.origin:sub(1, #vim.g.wiki_root) == vim.g.wiki_root) or url.origin == "" then
		-- print("in the wiki root start block")
		--
		-- if the "origin" (the file that contains the link) is in the wiki_root,
		-- the wiki_root directory is recursively searched for the file name;
		--
		-- an empty origin, like you'd get from <leader>ww, is also mapped to this block
		url.path = find_wiki_path_for_file(filename)
	-- print("in the wiki root")
	else
		-- print("not in the wiki root start block")
		-- if the origin is not in the wiki_root,
		-- fall back to only looking in the same directory as the origin
		url.path = url.origin:match(".*/") .. filename
		-- print("not in the wiki root")
	end

	-- print(vim.inspect(url))

	return url
end

vim.g.wiki_link_schemes = {
	wiki = {
		resolver = resolve_wiki_link,
		-- handler = function(x) print(vim.inspect(x)) end,
	},
}

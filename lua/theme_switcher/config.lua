local M = {}

M.defaults = {
	themes = {},
	default = nil,
	keymap = "<leader>ctt",
	plugins = {
		modicator = false,
		lualine = false,
	},
	custom_logic = false,
	logic_fn = function()
		return M.defaults.themes[1] and M.defaults.themes[1].name or "default"
	end,
}

M.options = {}

function M.setup(opts)
	M.options = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
end

return M

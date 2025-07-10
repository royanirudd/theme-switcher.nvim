local M = {}

M.defaults = {
	themes = {},
	default = nil,
	keymap = "<leader>ut",
	plugins = {
		modicator = false,
		lualine = false,
	},

	custom_logic = false,

	logic_fn = function()
		if M.options and M.options.themes and #M.options.themes > 0 then
			return M.options.themes[1].name
		end
		return nil
	end,
}

M.options = {}

function M.setup(opts)
	M.options = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
end

return M

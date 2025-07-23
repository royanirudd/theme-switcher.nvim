local config = require("theme_switcher.config")

local M = {}

local function find_theme(name)
	if not name then
		return nil, nil
	end
	for i, theme in ipairs(config.options.themes) do
		if theme.name == name or theme.colorscheme == name then
			return theme, i
		end
	end
	return nil, nil
end

local function apply_theme(colorscheme_name, silent)
	if not colorscheme_name then
		vim.notify("Theme Switcher: No theme name provided.", vim.log.levels.WARN)
		return
	end
	if vim.g.colors_name == colorscheme_name then
		return
	end
	local success, _ = pcall(vim.cmd.colorscheme, colorscheme_name)
	if success and not silent then
		vim.notify("Switched theme to: " .. colorscheme_name)
	elseif not success then
		vim.notify("Theme Switcher: Could not load colorscheme '" .. colorscheme_name .. "'.", vim.log.levels.ERROR)
	end
end

function M.apply_logic()
	local cfg = config.options

	if vim.bo.buftype ~= "" or vim.b.theme_switcher_override then
		return
	end

	if not (cfg.custom_logic and type(cfg.logic_fn) == "function") then
		return
	end

	local success, theme_name = pcall(cfg.logic_fn)
	if not (success and theme_name) then
		return
	end

	local theme_obj, _ = find_theme(theme_name)
	if theme_obj then
		local colorscheme_to_apply = theme_obj.colorscheme or theme_obj.name
		apply_theme(colorscheme_to_apply, true)
	end
end

local function toggle_theme()
	local themes = config.options.themes
	if not themes or #themes < 2 then
		vim.notify("Theme Switcher: At least two themes are required to toggle.", vim.log.levels.WARN)
		return
	end

	local _, current_index = find_theme(vim.g.colors_name)
	if not current_index then
		current_index = 1 -- Fallback if current theme isn't in our list.
	end

	local next_index = current_index + 1
	if next_index > #themes then
		next_index = 1
	end

	local next_theme = themes[next_index]
	if next_theme then
		local theme_to_apply = next_theme.colorscheme or next_theme.name
		apply_theme(theme_to_apply, false) -- Notify on manual toggle.

		vim.b.theme_switcher_override = theme_to_apply
	end
end

function M.setup(opts)
	config.setup(opts)

	M.apply_logic()

	local override_group = vim.api.nvim_create_augroup("ThemeSwitcherOverride", { clear = true })
	vim.api.nvim_create_autocmd("BufEnter", {
		group = override_group,
		pattern = "*",
		callback = function()
			if vim.b.theme_switcher_override then
				apply_theme(vim.b.theme_switcher_override, true)
			end
		end,
	})

	if config.options.keymap then
		vim.keymap.set("n", config.options.keymap, toggle_theme, {
			noremap = true,
			silent = true,
			desc = "Toggle theme",
		})
	end
end

return {
	setup = M.setup,
	apply_logic = M.apply_logic,
}

local config = require("theme_switcher.config")

local M = {}

local current_theme_index = 1

local function apply_theme(colorscheme_name, silent)
	if not colorscheme_name then
		vim.notify("Theme Switcher: No theme name provided.", vim.log.levels.WARN)
		return
	end

	local success, _ = pcall(vim.cmd.colorscheme, colorscheme_name)

	if success and not silent then
		vim.notify("Switched theme to: " .. colorscheme_name)
	elseif not success then
		vim.notify("Theme Switcher: Could not load colorscheme '" .. colorscheme_name .. "'.", vim.log.levels.ERROR)
	end
end

local function toggle_theme()
	local themes = config.options.themes
	if not themes or #themes == 0 then
		vim.notify("Theme Switcher: No themes configured.", vim.log.levels.WARN)
		return
	end

	current_theme_index = current_theme_index + 1
	if current_theme_index > #themes then
		current_theme_index = 1
	end

	local next_theme = themes[current_theme_index]
	if next_theme then
		local theme_to_apply = next_theme.colorscheme or next_theme.name
		apply_theme(theme_to_apply, false)
	end
end

function M.setup(opts)
	config.setup(opts)
	local cfg = config.options

	local initial_theme_name
	local initial_colorscheme

	if cfg.custom_logic and type(cfg.logic_fn) == "function" then
		local success, result = pcall(cfg.logic_fn)
		if success and result then
			initial_theme_name = result
		else
			vim.notify("Theme Switcher: custom logic function failed or returned nil.", vim.log.levels.WARN)
		end
	elseif cfg.default then
		initial_theme_name = cfg.default
	end

	if initial_theme_name then
		local found = false
		for i, theme in ipairs(cfg.themes) do
			if theme.name == initial_theme_name then
				current_theme_index = i
				initial_colorscheme = theme.colorscheme or theme.name
				found = true
				break
			end
		end
		if not found then
			vim.notify(
				"Theme Switcher: Initial theme '" .. initial_theme_name .. "' not found in themes list.",
				vim.log.levels.WARN
			)
		end
	end

	if not initial_colorscheme and cfg.themes and #cfg.themes > 0 then
		local first_theme = cfg.themes[1]
		initial_colorscheme = first_theme.colorscheme or first_theme.name
		current_theme_index = 1
	end

	if initial_colorscheme then
		vim.schedule(function()
			apply_theme(initial_colorscheme, true)
		end)
	end

	if cfg.keymap then
		vim.keymap.set("n", cfg.keymap, toggle_theme, {
			noremap = true,
			silent = true,
			desc = "Toggle theme",
		})
	end
end

return M

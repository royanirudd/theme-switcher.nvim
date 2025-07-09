local config = require("theme_switcher.config")

local M = {}
local current_theme_index = 1

local function apply_theme(theme_name)
	if not theme_name then
		vim.notify("Theme Switcher: No theme name provided.", vim.log.levels.WARN)
		return
	end

	local success, _ = pcall(vim.cmd.colorscheme, theme_name)
	if success then
		vim.notify("Switched theme to: " .. theme_name)
	else
		vim.notify("Theme Switcher: Could not load colorscheme '" .. theme_name .. "'.", vim.log.levels.ERROR)
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
	if next_theme and next_theme.name then
		apply_theme(next_theme.name)
	end
end

function M.setup(opts)
	config.setup(opts)
	local cfg = config.options

	if cfg.default then
		for i, theme in ipairs(cfg.themes) do
			if theme.name == cfg.default then
				current_theme_index = i
				break
			end
		end
	end

	local initial_theme
	if cfg.default and not cfg.custom_logic then
		initial_theme = cfg.default
	elseif cfg.themes and #cfg.themes > 0 then
		initial_theme = cfg.themes[1].name
	end

	if initial_theme then
		vim.schedule(function()
			apply_theme(initial_theme)
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

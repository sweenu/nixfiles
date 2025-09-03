local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.default_prog = { 'tmux' }
config.term = 'wezterm'

-- Appearance
config.enable_tab_bar = false
config.window_background_opacity = 0.78
config.window_content_alignment = {
  horizontal = 'Center',
  vertical = 'Center',
}
config.window_decorations = "NONE"
config.font_size = 10.0
-- Use dynamic themeing from Caelestia
-- config.color_scheme = 'OceanicNext (base16)'

-- Key bindings
config.disable_default_key_bindings = true
config.keys = {
  {
    key = 'c',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.CopyTo 'Clipboard',
  },
  {
    key = 'v',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.PasteFrom 'Clipboard',
  },
}

return config

local act = wezterm.action
local config = wezterm.config_builder()

-- tabline config (need tabline.setup before apply_to_config, which I need before the rest)
local tabline = require "tabline"
tabline.setup({
  options = {
    icons_enabled = false,
    theme = config.colors,
    section_separators = {
      left = wezterm.nerdfonts.ple_right_half_circle_thick,
      right = wezterm.nerdfonts.ple_left_half_circle_thick,
    },
    component_separators = {
      left = wezterm.nerdfonts.ple_right_half_circle_thin,
      right = wezterm.nerdfonts.ple_left_half_circle_thin,
    },
    tab_separators = {
      left = wezterm.nerdfonts.ple_right_half_circle_thick,
      right = wezterm.nerdfonts.ple_left_half_circle_thick,
    },
  },
  sections = {
    tabline_a = { 'mode' },
    tabline_b = { },
    tabline_c = { },
    tab_active = { { 'cwd', padding = { left = 0, right = 1 } }, },
    tab_inactive = { { 'cwd', padding = { left = 0, right = 1 } } },
    tabline_x = { },
    tabline_y = { 'battery', 'datetime' },
    tabline_z = { },
  },
})

tabline.apply_to_config(config)

-- Wezterm config
config.term = 'wezterm'
config.window_background_opacity = 0.7
config.window_content_alignment = { horizontal = 'Center', vertical = 'Center' }
config.window_decorations = 'NONE'
config.font_size = 10.0
config.disable_default_key_bindings = true
config.unzoom_on_switch_pane = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.quick_select_remove_styling = true
config.inactive_pane_hsb = { saturation = 0.9, brightness = 0.5 }

-- Keys
config.leader = { key = 'g', mods = 'ALT' }
config.keys = {
  -- Copy/paste
  { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo 'Clipboard' },
  { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom 'Clipboard' },

  -- Pane navigation
  { key = 'h', mods = 'CTRL', action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'CTRL', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'CTRL', action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'CTRL', action = act.ActivatePaneDirection 'Right' },

  -- Resize panes
  { key = 'LeftArrow',  mods = 'CTRL', action = act.AdjustPaneSize { 'Left',  2 } },
  { key = 'RightArrow', mods = 'CTRL', action = act.AdjustPaneSize { 'Right', 2 } },
  { key = 'UpArrow',    mods = 'CTRL', action = act.AdjustPaneSize { 'Up',    2 } },
  { key = 'DownArrow',  mods = 'CTRL', action = act.AdjustPaneSize { 'Down',  2 } },

  -- Split panes
  { key = 'v', mods = 'LEADER',  action = act.SplitVertical   { domain = 'CurrentPaneDomain' } },
  { key = 'h', mods = 'LEADER',  action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },

  { key = 'Enter', mods = 'ALT', action = act.SpawnTab 'CurrentPaneDomain' },

  -- Zoom/unzoom focused pane
  { key = 'Tab', mods = 'ALT', action = act.TogglePaneZoomState },

  -- Kill pane / kill tab
  -- { key = 'x', mods = 'CTRL',         action = act.CloseCurrentPane { confirm = true } },
  -- { key = 'x', mods = 'CTRL|SHIFT',   action = act.CloseCurrentTab  { confirm = true } },

  -- Prev/Next tab
  { key = 'p', mods = 'ALT', action = act.ActivateTabRelative(-1) },
  { key = 'n', mods = 'ALT', action = act.ActivateTabRelative(1) },

  -- Select tabs by number
  { key = '1', mods = 'ALT', action = act.ActivateTab(0) },
  { key = '2', mods = 'ALT', action = act.ActivateTab(1) },
  { key = '3', mods = 'ALT', action = act.ActivateTab(2) },
  { key = '4', mods = 'ALT', action = act.ActivateTab(3) },
  { key = '5', mods = 'ALT', action = act.ActivateTab(4) },
  { key = '6', mods = 'ALT', action = act.ActivateTab(5) },
  { key = '7', mods = 'ALT', action = act.ActivateTab(6) },
  { key = '8', mods = 'ALT', action = act.ActivateTab(7) },
  { key = '9', mods = 'ALT', action = act.ActivateTab(8) },
  { key = '0', mods = 'ALT', action = act.ActivateTab(9) },

  -- Last tab
  { key = ",", mods = 'LEADER', action = act.ActivateLastTab },

  -- Change font size
  { key = "=", mods = "CTRL", action = act.IncreaseFontSize },
  { key = "-", mods = "CTRL", action = act.DecreaseFontSize },
  { key = "0", mods = "CTRL", action = act.ResetFontSize },

  -- Search
  { key = "/", mods = "ALT", action = act.Search {CaseSensitiveString=""} },

  -- Copy and quick select modes
  { key = ' ', mods = 'CTRL|ALT', action = act.ActivateCopyMode },
  { key = 'o', mods = 'CTRL|ALT', action = act.QuickSelect },
  {
    key = 'O',
    mods = 'CTRL|ALT',
    action = wezterm.action.QuickSelectArgs {
      label = 'Open',
      skip_action_on_paste = true,
      action = wezterm.action_callback(function(window, pane)
        local selection = window:get_selection_text_for_pane(pane)
        wezterm.open_with(selection)
      end),
    },
  },

  -- Clear history/viewport
  { key = 'k', mods = 'CTRL|SHIFT', action = act.ClearScrollback 'ScrollbackAndViewport' },

  -- Move current pane to a new tab
  {
    key = 'w',
    mods = 'CTRL|SHIFT',
    action = wezterm.action_callback(function(window, pane)
      pane:move_to_new_tab()
    end),
  },
}

return config

local wezterm = require 'wezterm'

return {
  color_scheme = "MonokaiPro (Gogh)",
  keys = {
    -- Turn off the default CMD-m Hide action, allowing CMD-m to
    -- be potentially recognized and handled by the tab
    {
      key = 'k',
      mods = 'CMD|CTRL',
      action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
    },
    {
      key = 'j',
      mods = 'CMD|CTRL',
      action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
    },
    {
      key = 'j',
      mods = 'CTRL',
      action = wezterm.action.ActivatePaneDirection 'Down',
    },
    {
      key = 'k',
      mods = 'CTRL',
      action = wezterm.action.ActivatePaneDirection 'Up',
    },
    {
      key = 'l',
      mods = 'CTRL',
      action = wezterm.action.ActivatePaneDirection 'Right',
    },
    {
      key = 'h',
      mods = 'CTRL',
      action = wezterm.action.ActivatePaneDirection 'Left',
    },
  },
}

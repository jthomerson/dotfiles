-- See https://www.youtube.com/watch?v=e34qllePuoc
local wezterm = require("wezterm")
local act = wezterm.action
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")

-- Per-machine overrides (ssh_domains, unix_domains, etc.) live in local.lua,
-- which is gitignored so each computer can have its own.
local ok, local_config = pcall(require, "local")
if not ok then
   local_config = {}
end

-- Herdr binds these Cmd keys itself (see herdr/config.toml), but WezTerm uses them too, so
-- when the pane is running Herdr, pass the key on as its kitty keyboard protocol code.
-- SendKey would drop the Cmd.
local function herdr_or(kitty_code, wezterm_action)
   return wezterm.action_callback(function(window, pane)
      local process = pane:get_foreground_process_name() or ""

      if process:match("herdr$") then
         window:perform_action(act.SendString(kitty_code), pane)
         return
      end
      window:perform_action(wezterm_action, pane)
   end)
end

-- The kitty code for Cmd+arrow, or Cmd+Opt+arrow: modifier 9 is Cmd, 11 is Cmd+Opt
local function navigate_pane(direction, modifier)
   local arrow_codes = { Left = "D", Right = "C", Up = "A", Down = "B" }

   return herdr_or("\x1b[1;" .. modifier .. arrow_codes[direction], act.ActivatePaneDirection(direction))
end

-- The Gogh port of Tomorrow Night Bright sets bright black (ANSI 8) to the background
-- color, which hides any text printed in gray, such as a CLI prompt's choices. Use
-- Tomorrow's own comment gray instead.
local color_scheme = wezterm.color.get_builtin_schemes()["Tomorrow Night Bright (Gogh)"]
color_scheme.brights[1] = "#969896"

config = wezterm.config_builder()

config = {
   automatically_reload_config = true,
   -- Lets Herdr see Cmd keys; only programs that ask for the protocol get it
   enable_kitty_keyboard = true,
   -- Treat Option as Alt (not macOS compose) so Alt-based keybindings reach
   -- the terminal, e.g. Helix A-r/A-w reflow. Gives up special-char composition.
   send_composed_key_when_left_alt_is_pressed = false,
   send_composed_key_when_right_alt_is_pressed = false,
   window_decorations = "RESIZE", -- disable the title bar but enable the resizable border
   default_cursor_style = "BlinkingBar",
   color_schemes = { ["Tomorrow Night Bright (readable gray)"] = color_scheme },
   color_scheme = "Tomorrow Night Bright (readable gray)",
   -- font = wezterm.font("JetBrains Mono"), -- default
   -- font = wezterm.font("JetBrains Mono", { weight = "Bold" }),
   -- font = wezterm.font("ComicShannsMono Nerd Font", {weight="Regular", stretch="Normal", style="Normal"}),
   font = wezterm.font("SauceCodePro Nerd Font Mono", {weight="Regular", stretch="Normal", style="Normal"}), -- (AKA: SauceCodePro NFM)
   font_size = 13.5,
   inactive_pane_hsb = {
      saturation = 0.5,
      brightness = 0.4,
   },

   ssh_domains = local_config.ssh_domains or {},
   unix_domains = local_config.unix_domains or {},

   keys = {
      -- iTerm2-style pane splitting
      -- Cmd+D: split right (vertical divider), like iTerm2
      { key = "d", mods = "CMD", action = act.SplitPane({ direction = "Right" }) },
      -- Cmd+Shift+D: split down (horizontal divider), like iTerm2
      { key = "d", mods = "CMD|SHIFT", action = act.SplitPane({ direction = "Down" }) },

      -- iTerm2-style pane navigation
      -- Cmd+[ / Cmd+]: cycle through panes, or Herdr's tabs
      { key = "[", mods = "CMD", action = herdr_or("\x1b[91;9u", act.ActivatePaneDirection("Prev")) },
      { key = "]", mods = "CMD", action = herdr_or("\x1b[93;9u", act.ActivatePaneDirection("Next")) },
      -- Cmd+Arrow or Cmd+Opt+Arrow: navigate to adjacent pane directionally
      { key = "LeftArrow",  mods = "CMD",     action = navigate_pane("Left", 9) },
      { key = "RightArrow", mods = "CMD",     action = navigate_pane("Right", 9) },
      { key = "UpArrow",    mods = "CMD",     action = navigate_pane("Up", 9) },
      { key = "DownArrow",  mods = "CMD",     action = navigate_pane("Down", 9) },
      { key = "LeftArrow",  mods = "CMD|OPT", action = navigate_pane("Left", 11) },
      { key = "RightArrow", mods = "CMD|OPT", action = navigate_pane("Right", 11) },
      { key = "UpArrow",    mods = "CMD|OPT", action = navigate_pane("Up", 11) },
      { key = "DownArrow",  mods = "CMD|OPT", action = navigate_pane("Down", 11) },
      -- Cmd+Shift+Enter: toggle pane zoom (full-screen within window), or Herdr's
      { key = "Enter", mods = "CMD|SHIFT", action = herdr_or("\x1b[13;10u", act.TogglePaneZoomState) },
      -- Cmd+Opt+[ / Cmd+Opt+]: rotate/move panes (swap current pane left/right)
      { key = "[", mods = "CMD|OPT", action = act.RotatePanes("CounterClockwise") },
      { key = "]", mods = "CMD|OPT", action = act.RotatePanes("Clockwise") },
      -- Cmd+Opt+Shift+[ / Cmd+Opt+Shift+]: move tab left/right
      { key = "[", mods = "CMD|OPT|SHIFT", action = act.MoveTabRelative(-1) },
      { key = "]", mods = "CMD|OPT|SHIFT", action = act.MoveTabRelative(1) },

      -- Option+Arrow: jump words (send escape sequences for shells/readline)
      { key = "LeftArrow",  mods = "OPT", action = act.SendString("\x1bb") },
      { key = "RightArrow", mods = "OPT", action = act.SendString("\x1bf") },

      -- Cmd+Shift+R: rename current tab
      {
         key = "r", mods = "CMD|SHIFT",
         action = act.PromptInputLine {
            description = "Rename tab:",
            action = wezterm.action_callback(function(window, _, line)
               if line then window:active_tab():set_title(line) end
            end),
         },
      },

      -- Cmd+Shift+S: save workspace state (resurrect.wezterm)
      {
         key = "s", mods = "CMD|SHIFT",
         action = wezterm.action_callback(function(_, _)
            local state = resurrect.workspace_state.get_workspace_state()
            local name = state.workspace .. "-" .. wezterm.strftime("%Y-%m-%d-%H.%M.%S")
            resurrect.state_manager.save_state(state, name)
         end),
      },
      -- Cmd+Shift+O: open a saved state via fuzzy finder (resurrect.wezterm)
      {
         key = "o", mods = "CMD|SHIFT",
         action = wezterm.action_callback(function(win, pane)
            resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, _)
               local kind = string.match(id, "^([^/]+)")
               id = string.match(id, "([^/]+)$")
               id = string.match(id, "(.+)%..+$")
               local opts = {
                  relative = true,
                  restore_text = true,
                  on_pane_restore = resurrect.tab_state.default_on_pane_restore,
               }
               if kind == "workspace" then
                  local state = resurrect.state_manager.load_state(id, "workspace")
                  resurrect.workspace_state.restore_workspace(state, opts)
               elseif kind == "window" then
                  local state = resurrect.state_manager.load_state(id, "window")
                  resurrect.window_state.restore_window(pane:window(), state, opts)
               elseif kind == "tab" then
                  local state = resurrect.state_manager.load_state(id, "tab")
                  resurrect.tab_state.restore_tab(pane:tab(), state, opts)
               end
            end)
         end),
      },
   },
}

-- Auto-save workspace state every 5 minutes so a restart can pick up where we left off.
resurrect.state_manager.periodic_save({
   interval_seconds = 300,
   save_workspaces = true,
   save_windows = true,
   save_tabs = true,
})

-- On GUI startup, restore the latest saved state written by periodic_save.
wezterm.on("gui-startup", resurrect.state_manager.resurrect_on_gui_startup)


return config

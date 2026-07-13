local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- OS判定（環境ごとに設定を分岐するため）
local triple = wezterm.target_triple
local is_windows = triple:find("windows") ~= nil
local is_mac = triple:find("darwin") ~= nil
local is_linux = not is_windows and not is_mac

config.automatically_reload_config = true

-- 起動時のウィンドウサイズ（列×行）少しだけ大きめに
config.initial_cols = 120
config.initial_rows = 32
-- WebGpu は AMD iGPU + Windows で透過(アルファ合成)が効かないことがあるため OpenGL に。
-- 透過が出たら原因はWebGpu。WebGpuに戻したい場合は下行に変更:
-- config.front_end = "WebGpu"
config.front_end = "OpenGL"
config.font = wezterm.font_with_fallback({
  "HackGen Console NF",
  "JetBrains Mono",
})
config.font_size = 12.0
config.use_ime = true
-- 背景の透過 (0=透明, 1=不透明)
-- PowerShell (Windows Terminal) の opacity:80 に合わせて 0.80
config.window_background_opacity = 0.80

-- 背景ブラー（OSごとに対応プロパティが違うので分岐）
if is_mac then
  config.macos_window_background_blur = 20
elseif is_windows then
  -- Acrylic は Windows の「透明効果」設定や WebGpu と相性問題で
  -- 効かないことがあるため、純粋な opacity 透過に切替え（確実に効く）
  -- すりガラスに戻したい場合は下行を有効化:
  -- config.win32_system_backdrop = "Acrylic"
end

-- カーソル点滅: 完全にオフ（常に点灯）
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"
config.cursor_blink_rate = 0
config.default_cursor_style = "SteadyBlock"

----------------------------------------------------
-- Tab
----------------------------------------------------
config.window_decorations = "RESIZE"
config.show_tabs_in_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false

config.window_frame = {
  inactive_titlebar_bg = "none",
  active_titlebar_bg = "none",
}

-- 黒塗りの背景は透過/Acrylicを隠すので無効化
-- config.window_background_gradient = {
--   colors = { "#000000" },
-- }

config.show_new_tab_button_in_tab_bar = false
-- 各タブの閉じるボタンを非表示にするオプション (nightly限定。安定版20240203には無いため無効化)
-- config.show_close_tab_button_in_tabs = false

config.colors = {
  tab_bar = {
    inactive_tab_edge = "none",
  },
}

local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_left_half_circle_thick
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_right_half_circle_thick

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local background = "#5c6d74"
  local foreground = "#FFFFFF"
  local edge_background = "none"
  if tab.is_active then
    background = "#1e3a8a"
    foreground = "#FFFFFF"
  end
  local edge_foreground = background
  local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "
  return {
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_LEFT_ARROW },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = title },
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_RIGHT_ARROW },
  }
end)

----------------------------------------------------
-- keybinds
----------------------------------------------------
config.disable_default_key_bindings = true
config.keys = require("keybinds").keys
config.key_tables = require("keybinds").key_tables
-- 物理Ctrlキーを leader にする。Mac側は Karabiner の Cmd<->Ctrl 入れ替えから
-- WezTerm を除外しているので、両OSとも物理キーがそのまま届く
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 2000 }

return config

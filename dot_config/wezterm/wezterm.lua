local wezterm = require("wezterm")

local config = wezterm.config_builder()

config = {
	automatically_reload_config = true,
	enable_tab_bar = false,
	window_close_confirmation = "NeverPrompt",
	window_decorations = "RESIZE",
	color_scheme = "Tokyo Night",
	font = wezterm.font("JetBrains Mono", { weight = "Bold" }),
	send_composed_key_when_left_alt_is_pressed = true,
	send_composed_key_when_right_alt_is_pressed = false,
	font_size = 15.0,
}
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }
return config

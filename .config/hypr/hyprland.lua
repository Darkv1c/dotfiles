-- Hyprland 0.55+ Lua config
-- Migrated from hyprlang

------------------
---- MONITORS ----
------------------

hl.monitor({ output = "eDP-1", mode = "1920x1200@60", position = "0x0", scale = 1.5 })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "0x0", scale = 1.5, mirror = "eDP-1" })

---------------------
---- MY PROGRAMS ----
---------------------

local terminal = "kitty -e tmux"
local fileManager = "kitty -e yazi"
local menu = "rofi -show-icons -show drun"
local BROWSER = "zen-browser"

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
	hl.exec_cmd("waypaper --restore")
	hl.exec_cmd("xsettingsd")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Adwaita")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("EDITOR", "nvim")
hl.env("SHELL", "zsh")
hl.env("PATH", os.getenv("HOME") .. "/.local/bin:" .. (os.getenv("PATH") or ""))
hl.env("BROWSER", os.getenv("HOME") .. "/.local/bin/zen")
hl.env("GTK_THEME", "Adwaita:dark")
hl.env("QT_QPA_PLATFORMTHEME", "xdgdesktopportal")

-----------------------
----- PERMISSIONS -----
-----------------------

hl.config({
	ecosystem = {
		enforce_permissions = true,
	},
})

hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 20,
		border_size = 2,
		col = {
			active_border = { colors = { "rgba(ffffffee)", "rgba(00000000)", "rgba(ffffffee)" }, angle = 45 },
			inactive_border = "rgba(595959aa)",
		},
		resize_on_border = false,
		allow_tearing = false,
		layout = "dwindle",
	},

	decoration = {
		rounding = 10,
		rounding_power = 2,
		active_opacity = 1.0,
		inactive_opacity = 1.0,
		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = 0xee1a1a1a,
		},
		blur = {
			enabled = true,
			size = 5,
			passes = 3,
			vibrancy = 1,
		},
	},
})

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

------------------------
---- LAYOUT OPTIONS ----
------------------------

hl.config({
	dwindle = {
		preserve_split = true,
	},
})

hl.config({
	master = {
		new_status = "slave",
		orientation = "left",
	},
})

---------------
---- MISC ----
---------------

hl.config({
	misc = {
		force_default_wallpaper = -1,
		disable_hyprland_logo = false,
	},
})

---------------
---- INPUT ----
---------------

hl.config({
	input = {
		kb_layout = "latam",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",
		follow_mouse = 1,
		sensitivity = 0,
		mouse_refocus = false,
		touchpad = {
			natural_scroll = true,
		},
	},
})

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})

hl.config({
	cursor = {
		no_warps = true,
		inactive_timeout = 5,
		hide_on_key_press = true,
		warp_on_change_workspace = 0,
	},
})

------------------
---- KEYBINDS ----
------------------

local M = "SUPER"

-- Launch programs
hl.bind(M .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind("CTRL + SHIFT + W", hl.dsp.window.close())
hl.bind(M .. " + W", hl.dsp.window.close())
hl.bind(M .. " + M", hl.dsp.exit())
hl.bind(M .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(M .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind("CTRL + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(M .. " + P", hl.dsp.window.pseudo())
hl.bind(M .. " + B", hl.dsp.exec_cmd(BROWSER))

-- Focus movement
hl.bind(M .. " + ALT + H", hl.dsp.focus({ direction = "left" }))
hl.bind(M .. " + ALT + L", hl.dsp.focus({ direction = "right" }))
hl.bind(M .. " + ALT + K", hl.dsp.focus({ direction = "up" }))
hl.bind(M .. " + ALT + J", hl.dsp.focus({ direction = "down" }))

-- Media
hl.bind(M .. " + SPACE", hl.dsp.exec_cmd("playerctl play-pause"))

-- Fullscreen
hl.bind(M .. " + F", hl.dsp.window.fullscreen({ action = "set" }))
hl.bind(M .. " + SHIFT + F", hl.dsp.window.fullscreen({ action = "set", mode = "maximized" }))

-- Workspace switching
for i = 1, 10 do
	local key = i % 10
	hl.bind(M .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(M .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Screenshots
hl.bind(M .. " + mouse:277", hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind(M .. " + ALT + END", hl.dsp.exec_cmd("hyprshot -m output"))
hl.bind(M .. " + CTRL + ALT + END", hl.dsp.exec_cmd("hyprshot -m window"))

-- Scratchpad
hl.bind(M .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(M .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Workspace scrolling
hl.bind(M .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("ALT + tab", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("ALT + SHIFT + tab", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(M .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Mouse move/resize
hl.bind(M .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(M .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Swap windows
hl.bind(M .. " + CTRL + H", hl.dsp.window.swap({ direction = "left" }))
hl.bind(M .. " + CTRL + L", hl.dsp.window.swap({ direction = "right" }))
hl.bind(M .. " + CTRL + K", hl.dsp.window.swap({ direction = "up" }))
hl.bind(M .. " + CTRL + J", hl.dsp.window.swap({ direction = "down" }))

-- Multimedia keys
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

--------------------------------
---- WINDOW RULES (Textern) ----
--------------------------------

hl.window_rule({
	name = "textern-edit",
	match = { title = "^(textern-edit)$" },
	float = true,
})

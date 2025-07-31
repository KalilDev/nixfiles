{config, lib, pkgs, ...}: 
  let
    custom = config.custom;
    enable = custom.hyprland-session.enable;
    super = custom.hyprland-session.mod;
    mod = custom.hyprland-session.mod;
    mod_shift = custom.hyprland-session.mod_shift;
    toList = value: if builtins.isList value then value else [value];
    left = toList custom.hyprland-session.left;
    right = toList custom.hyprland-session.right;
    up = toList custom.hyprland-session.up;
    down = toList custom.hyprland-session.down;
    terminal = custom.hyprland-session.terminal;
    bar-command = custom.hyprland-session.bar.command;
    package = custom.hyprland-session.package;
    plugins = custom.hyprland-session.plugins;
    portalPackage = custom.hyprland-session.portalPackage;
    background = custom.hyprland-session.background;
  in {
  config = lib.mkIf enable {
    home.packages = with pkgs; [
        playerctl
        brightnessctl
        nordzy-cursor-theme
    ];
    services.hyprpaper = {
        enable = true;
        settings = {
        ipc = "on";
        splash = false;
        splash_offset = 2.0;

        preload =
            [ background ];

        wallpaper = [
            ", ${background}"
        ];        
        };
    };
    services.hypridle = {
        enable = true;
        settings = {
            general = {
            after_sleep_cmd = "hyprctl dispatch dpms on";
            ignore_dbus_inhibit = false;
            lock_cmd = "hyprlock";
            };
            listener = [
            {
                timeout = 900;
                on-timeout = "hyprlock";
            }
            {
                timeout = 1200;
                on-timeout = "hyprctl dispatch dpms off";
                on-resume = "hyprctl dispatch dpms on";
            }
            ];
        };
    };
    programs.hyprlock = {
        enable = true;
        settings = {
            general = {
            disable_loading_bar = true;
            grace = 300;
            hide_cursor = true;
            no_fade_in = false;
            };

            background = [
            {
                path = "screenshot";
                blur_passes = 3;
                blur_size = 8;
            }
            ];
            input-field = [
            {
                size = "200, 50";
                position = "0, -80";
                monitor = "";
                dots_center = true;
                fade_on_empty = false;
                font_color = "rgb(202, 211, 245)";
                inner_color = "rgb(91, 96, 120)";
                outer_color = "rgb(24, 25, 38)";
                outline_thickness = 5;
                placeholder_text = ''<span foreground="##cad3f5">Password...</span>'';
                shadow_passes = 2;
            }
            ];
        };
    };
    wayland.windowManager.hyprland = {
        enable = true;
        xwayland.enable = true;
        systemd.enable = true;
        systemd.enableXdgAutostart = true;
        package = package;
        portalPackage = portalPackage;
        plugins = plugins;
        settings = {
            "$mod" = mod;
            experimental = {
                xx_color_management_v4 = true;
            };
            monitor = [
                "desc:LG Electronics LG ULTRAGEAR 502AZPU32496, 2560x1440@164.96Hz, 0x0, 1, bitdepth, 10, cm, hdredid, sdrbrightness, 1.15, sdrsaturation, 0.75"
            ];
            exec-once = [
		"hyprctl setcursor Nordzy-hyprcursors 32"
                "${bar-command}"
            ];
            "debug:disable_logs" = false;
            bindm = [
                "${mod}, mouse:272, hy3:movewindow"
            ];
            bind = [
                "${mod}, Return, exec, ${terminal}"
                "${mod}, D, exec, rofi -modes drun -show drun"
                "${mod}, H, hy3:makegroup, h, ephemeral"
                "${mod}, V, hy3:makegroup, v, ephemeral"
                "${mod}, S, hy3:changegroup, toggletab"
                "${mod}, W, hy3:changegroup, toggletab"
                "${mod}, E, hy3:changegroup, opposite"
                "${mod}, A, hy3:changefocus, raise"
                "${mod_shift}, A, hy3:changefocus, lower"
                "${mod_shift}, Q, killactive"
                "${mod}, space, hy3:togglefocuslayer"
                "${mod_shift}, space, togglefloating"
                "${mod}, F, fullscreen"
                "${mod_shift},MINUS,movetoworkspacesilent,special"
                "${mod},MINUS,togglespecialworkspace"
                "${mod}, R, submap, resize"
                ",XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5%"
                ",XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5%"
                ",XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle"
                ",XF86AudioMicMute, exec, pactl set-source-mute @DEFAULT_SOURCE@ toggle"
                ",XF86MonBrightnessDown, exec, brightnessctl set 5%-"
                ",XF86MonBrightnessUp, exec, brightnessctl set 5%+"
                ",XF86AudioPlay, exec, playerctl play-pause"
                ",XF86AudioPause, exec, playerctl play-pause"
                ",XF86AudioNext, exec, playerctl next"
                ",XF86AudioPrev, exec, playerctl previous"
                ",XF86AudioStop, exec, playerctl stop"
                ",Print, exec, flameshot gui"
                # thinkpad hack
                ",XF86NotificationCenter, exec, playerctl stop"
                ",XF86HangupPhone, exec, playerctl play-pause"
                ",XF86Favorites, exec, playerctl next"
                ",XF86PickupPhone, exec, playerctl previous"
            ]
            ++ (builtins.concatMap (left: [
                "${mod}, ${left}, hy3:movefocus, l"
                "${mod_shift}, ${left}, hy3:movewindow, l"
                ])
                left
            )
            ++ (builtins.concatMap (right: [
                "${mod}, ${right}, hy3:movefocus, r"
                "${mod_shift}, ${right}, hy3:movewindow, r"
                ])
                right
            )
            ++ (builtins.concatMap (up: [
                "${mod}, ${up}, hy3:movefocus, u"
                "${mod_shift}, ${up}, hy3:movewindow, u"
                ])
                up
            )
            ++ (builtins.concatMap (down: [
                "${mod}, ${down}, hy3:movefocus, d"
                "${mod_shift}, ${down}, hy3:movewindow, d"
                ])
                down
            )
            ++ (
                # workspaces
                # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
                builtins.concatLists (builtins.genList (i:
                    let ws = i + 1;
                    in [
                    "$mod, code:1${toString i}, workspace, ${toString ws}"
                    "$mod SHIFT, code:1${toString i}, movetoworkspacesilent, ${toString ws}"
                    ]
                )
                9)
            );
            env = [
                "_JAVA_AWT_WM_NONREPARENTING, 1"
                "GDK_BACKEND, wayland,x11,*"
                "QT_QPA_PLATFORM, wayland-egl;wayland;xcb"
                "QT_AUTO_SCREEN_SCALE_FACTOR, 1"
                #env = QT_QPA_PLATFORMTHEME,qt5ct
                "QT_WAYLAND_DISABLE_WINDOWDECORATION, 1"
                "ECORE_EVAS_ENGINE, wayland_egl"
                "ELM_ENGINE, wayland_egl"
                "SDL_VIDEODRIVER, wayland"
                "CLUTTER_BACKEND, wayland"
                "XDG_CURRENT_DESKTOP, Hyprland"
                "XDG_SESSION_TYPE, wayland"
                "XDG_SESSION_DESKTOP, Hyprland"
        #export QT_WAYLAND_FORCE_DPI=physical
            ];
        };
        extraConfig = let
            mkMode = {name, bind, binde}: lib.concatStrings (builtins.map (line: "${line}\n") ([
                "submap = ${name}"
                "bind = , escape, submap, reset"
            ] ++ (builtins.map (bind: "bind = ${bind}") bind)
	      ++ (builtins.map (binde: "binde = ${binde}") binde)
              ++ ["submap = reset"]));
            in ''

        # Monitor (adjust as needed)
        monitor=,preferred,auto,1

        # Input config
        input {
            kb_layout = us,us,us
            kb_variant = intl,,colemak
            follow_mouse = 1
            touchpad {
            natural_scroll = true
            tap-to-click = true
            }
        }

        # General settings
        general {
            gaps_in = 24
            gaps_out = 12
            border_size = 2
            col.active_border = rgb(c868a6)
            col.inactive_border = rgb(151515)
            layout = hy3
        }

        # Decoration
        decoration {
            rounding = 0
        }

        # Animations (optional)
        animations {
            enabled = true
            bezier = ease, 0.4, 0.02, 0.21, 1
            animation = windows, 1, 7, ease
        }

        plugin {
            hy3 {
                no_gaps_when_only = 1
                node_collapse_policy = 0
                # group_inset = 10
                tab_first_window = false
                tabs {
                    # height = 22
                    # padding = 0
                    from_top = true
                    radius = 0
                    # border_width = 2
                    # render_text = true
                    # text_center = true
                    text_font = "monospace"
                    # text_height = 8
                    text_padding = 4

                    # active tab bar segment colors
                    col.active = rgb(c868a6)
                    col.active.border = rgb(c868a6)
                    col.active.text = rgba(000000E6)

                    # focused tab bar segment colors (focused node in unfocused container)
                    col.focused = rgb(c868a6)
                    col.focused.border = rgb(c868a6)
                    col.focused.text = rgba(000000E6)
                    
                    # inactive tab bar segment colors
                    col.inactive = rgb(151515) # default: rgba(30303020)
                    col.inactive.border = rgb(151515) # default: rgba(606060aa)
                    col.inactive.text = rgb(999999) # default: rgba(ffffffff)
                    
                    # urgent tab bar segment colors
                    col.urgent = rgb(c868a6)
                    col.urgent.border = rgb(c868a6)
                    col.urgent.text = rgba(000000E6)
                    
                    #   # urgent tab bar segment colors
                    #   col.locked = <color> # default: rgba(90903340)
                    #   col.locked.border = <color> # default: rgba(909033ee)
                    #   col.locked.text = <color> # default: rgba(ffffffff)
                    # blur = true
                    # opacity = 1.0
                }
                autotile {
                    enable = true
                    ephemeral_groups = true
                    trigger_width = 850
                    trigger_height = 480
                    # workspaces = "all"
                }
            }
        }
        ''
        + mkMode {
            name = "resize";
            binde = (builtins.map (left: ", ${left}, resizeactive, -10 0") left) ++
                (builtins.map (right: ", ${right}, resizeactive, 10 0") right) ++
                (builtins.map (up: ", ${up}, resizeactive, 0 -10") up) ++
                (builtins.map (down: ", ${down}, resizeactive, 0 10") down);
            bind = [
                "${mod}, R, submap, reset"
            ];
        };
    };
  };
}

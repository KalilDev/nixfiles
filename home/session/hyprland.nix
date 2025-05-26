{config, lib, pkgs, ...}: {
  imports = [
  ];
  config =
  let
    super = "SUPER";
  in {
    home.packages = with pkgs; [
      playerctl
      brightnessctl
    ];
    services.hyprpaper = {
      enable = true;
      settings = let
        darkBg = builtins.fetchurl {
          url = "https://raw.githubusercontent.com/KalilDev/dotfiles/refs/heads/master/.config/wallpaper/dark.png";
          sha256 = "0a43c0c023a0fd7f213f1ccc3caf0fae1a7c29ee538d75a95e722b59cdf4c843";
        };
        lightBg = builtins.fetchurl {
          url = "https://raw.githubusercontent.com/KalilDev/dotfiles/refs/heads/master/.config/wallpaper/light.png";
          sha256 = "fcf32cd741148c3874ca514fe04b28038888acdb703fbf68cf5478fe2fae83dd";
        };
      in {
        ipc = "on";
        splash = false;
        splash_offset = 2.0;

        preload =
          [ darkBg lightBg ];
  
        wallpaper = [
          darkBg
        ];        
      };
    };
    services.hypridle = {
      enable = true;
    };
    programs.hyprlock = {
      enable = true;
    };
    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      systemd.enable = true;
      systemd.enableXdgAutostart = true;
      package = hyprland;
      settings = lib.mkOptionDefault {
        experimental = {
          xx_color_management_v4 = true;
        };
        "debug:disable_logs" = false;
      };
  #export QT_WAYLAND_FORCE_DPI=physical
      extraConfig = ''
        env = _JAVA_AWT_WM_NONREPARENTING,1
        env = GDK_BACKEND,wayland,x11,*
        env = QT_QPA_PLATFORM,wayland-egl;wayland;xcb
        env = QT_AUTO_SCREEN_SCALE_FACTOR,1
        #env = QT_QPA_PLATFORMTHEME,qt5ct
        env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1
        env = ECORE_EVAS_ENGINE,wayland_egl
        env = ELM_ENGINE,wayland_egl
        env = SDL_VIDEODRIVER,wayland
        env = CLUTTER_BACKEND,wayland

        env = XDG_CURRENT_DESKTOP,Hyprland
        env = XDG_SESSION_TYPE,wayland
        env = XDG_SESSION_DESKTOP,Hyprland


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
          layout = dwindle
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

        # Keybindings
        bind = ${super}, Return, exec, "alacritty"
        bind = ${super}, Q, killactive
        bind = ${super}, D, exec, "rofi -modes drun -show drun"

        bind = ${super}, H, movefocus, l
        bind = ${super}, L, movefocus, r
        bind = ${super}, K, movefocus, u
        bind = ${super}, J, movefocus, d

        bind = ${super} SHIFT, H, movewindow, l
        bind = ${super} SHIFT, L, movewindow, r
        bind = ${super} SHIFT, K, movewindow, u
        bind = ${super} SHIFT, J, movewindow, d

        bind = ${super}, S, togglefloating
        bind = ${super}, F, fullscreen

        bind = ${super}, 1, workspace, 1
        bind = ${super} SHIFT, 1, movetoworkspace, 1
        bind = ${super}, 2, workspace, 2
        bind = ${super} SHIFT, 2, movetoworkspace, 2
        # ... repeat for 3-10

        bind = ,XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5%
        bind = ,XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5%
        bind = ,XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle
        bind = ,XF86AudioMicMute, exec, pactl set-source-mute @DEFAULT_SOURCE@ toggle
        bind = ,XF86MonBrightnessDown, exec, brightnessctl set 5%-
        bind = ,XF86MonBrightnessUp, exec, brightnessctl set 5%+

        # Scratchpad style behavior
        windowrulev2 = float, class:^(scratchpad)$
      '';
    };
  };
}

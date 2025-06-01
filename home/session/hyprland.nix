{config, lib, pkgs, ...}: 
  let
    super = "SUPER";
    mod = super;
    mod_shift = "SUPER_SHIFT";
    left = "left";
    right = "right";
    up = "up";
    down = "down";
  in {
  imports = [
    ./sway/waybar.nix
  ];
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
        ", ${darkBg}"
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
    package = pkgs.hyprland;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
    settings = {
      "$mod" = mod;
      experimental = {
        xx_color_management_v4 = true;
      };
      monitor = [
        "desc:LG Electronics LG ULTRAGEAR 502AZPU32496, 2560x1440@164.96Hz, 0x0, 1, bitdepth, 10, cm, hdredid, sdrbrightness, 1.15, sdrsaturation, 0.75"
      ];
      exec-once = [
        "waybar"
      ];
      "debug:disable_logs" = false;
      bindm = [
        "${mod}, mouse:272, movewindow"
      ];
      bind = [
        "${mod}, Return, exec, alacritty"
        "${mod}, D, exec, rofi -modes drun -show drun"
        "${mod}, ${left}, movefocus, l"
        "${mod}, ${right}, movefocus, r"
        "${mod}, ${up}, movefocus, u"
        "${mod}, ${down}, movefocus, d"
        "${mod_shift}, ${left}, movewindow, l"
        "${mod_shift}, ${right}, movewindow, r"
        "${mod_shift}, ${up}, movewindow, u"
        "${mod_shift}, ${down}, movewindow, d"
        "${mod_shift}, Q, killactive"
        "${mod_shift}, space, togglefloating"
        "${mod}, F, fullscreen"
      ]
      ++ (
        # workspaces
        # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
        builtins.concatLists (builtins.genList (i:
            let ws = i + 1;
            in [
              "$mod, code:1${toString i}, workspace, ${toString ws}"
              "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
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
    extraConfig = ''

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
}

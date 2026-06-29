{config, lib, pkgs, ...}: 
  let
    super = "Mod4";
  in {
  imports = [
    ./sway/flameshot.nix
    ./sway/waybar.nix
    ./sway/hdr.nix
  ];
  home.packages = with pkgs; [
    swaybg
    playerctl
    brightnessctl
    kanshi
  ];
  xdg.configFile."kanshi/kanshi.conf".text = "";
  systemd.user.services.kanshi-sway = {
    Unit = {
      Description = "kanshi daemon for sway session";
      WantedBy = "sway-session.target";
      Wants = "sway-session.target";
      After = "sway-session.target";
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.kanshi}/bin/kanshi -c ${config.xdg.configHome}/kanshi/kanshi.conf";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
  wayland.windowManager.sway = {
    enable = true;
    xwayland = true;
    systemd.enable = true;
    extraConfigEarly = ''
set $laptopDisplay eDP-1
'';
    extraConfig = ''
bindswitch --reload --locked lid:on output $laptopDisplay disable
bindswitch --reload --locked lid:off output $laptopDisplay enable

default_border pixel 2

## Dark
# class                   border      backgr.     text        indicator   child_border
client.focused           "#c868a6"   "#c868a6"   "#000000E6" "#000000E6" "#fd98d7"
#client.focused_inactive "#242424"   "#24242400" "#24242400" "#24242400" "#24242400" 
client.unfocused         "#151515"   "#151515"   "#999999"   "#999999"   "#151515"
#client.urgent           "#2E344000" "#2E344000" "#2E344000" "#2E344000" "#2E344000"
#client.placeholder      "#2E344000" "#2E344000" "#2E344000" "#2E344000" "#2E344000"
'';
    extraSessionCommands = ''
# Hack! dont use vulkan wlr renderer on nix builder
test "$XDG_SESSION_TYPE" = "wayland" && export WLR_RENDERER=vulkan
export _JAVA_AWT_WM_NONREPARENTING=1
export QT_QPA_PLATFORM=wayland-egl
#export QT_WAYLAND_FORCE_DPI=physical
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export ECORE_EVAS_ENGINE=wayland_egl
export ELM_ENGINE=wayland_egl
export SDL_VIDEODRIVER=wayland
export NIXOS_OZONE_WL=1
export ELECTRON_OZONE_PLATFORM_HINT=wayland
export XDG_CURRENT_DESKTOP=sway
    '';
    config = rec {
      gaps = {
        outer = 12;
        inner = 24;
        smartBorders = "on";
        smartGaps = true;
      };
      startup = let
        darkBg = builtins.fetchurl {
          url = "https://raw.githubusercontent.com/KalilDev/dotfiles/refs/heads/master/.config/wallpaper/dark.png";
          sha256 = "0a43c0c023a0fd7f213f1ccc3caf0fae1a7c29ee538d75a95e722b59cdf4c843";
        };
        lightBg = builtins.fetchurl {
          url = "https://raw.githubusercontent.com/KalilDev/dotfiles/refs/heads/master/.config/wallpaper/light.png";
          sha256 = "fcf32cd741148c3874ca514fe04b28038888acdb703fbf68cf5478fe2fae83dd";
        };
        clamshell-startup-script = pkgs.writeText "chamshell-startup.sh" ''
#!/bin/sh

LAPTOP_OUTPUT="eDP-1"
LID_STATE_FILE="/proc/acpi/button/lid/LID/state"

read -r LS < "$LID_STATE_FILE"

case "$LS" in
*open)   swaymsg output "$LAPTOP_OUTPUT" enable ;;
*closed) swaymsg output "$LAPTOP_OUTPUT" disable ;;
*)       echo "Could not get lid state" >&2 ; exit 1 ;;
esac    
    '';
        in [
          {
            command = "swaybg -m fill -i ${darkBg}";
            always = true;
          } 
          { command = "${clamshell-startup-script}"; } 
          { command = "${pkgs.kdePackages.kdeconnect-kde}/bin/kdeconnect-indicator"; }
      ];
      input = {
        "2:7:SynPS/2_Synaptics_TouchPad" = {
          accel_profile = "adaptive";
          drag = "enabled";
          # disable while trackpointing
          dwtp = "enabled";
          # disable while typing
          dwt = "enabled";
          natural_scroll = "enabled";
          pointer_accel = "0";
          tap = "enabled";
        };
        "2:10:TPPS/2_Elan_TrackPoint" = {
          accel_profile = "flat";
          pointer_accel = "0";
        };
        "1:1:AT_Translated_Set_2_keyboard" = {
          xkb_layout = "us,us,us";
          xkb_variant = "intl,,colemak";
        };
        "1267:10395:ELAN_Touchscreen" = {
          map_to_output = "eDP-1";
        };
      };
      modes = lib.mkOptionDefault {
        default = lib.mkOptionDefault {
          "${super}+F" = "fullscreen toggle";
        };
        resize = lib.mkOptionDefault {
          "${super}+F" = "fullscreen toggle";
        };
        game = {
          "${super}+Escape" = "mode default";
          "${super}+G" = "mode default";
        };
      };
      output = {
        "HDMI-A-1" = {
	  render_bit_depth = "10";
	  hdr = "on";
	};
        "DP-5" = {
	  render_bit_depth = "10";
	  hdr = "on";
	};
      };
      left = "h";
      down = "j";
      up = "k";
      right = "l";
      keybindings = {

        "${super}+Return" = "exec ${terminal}";
        "${super}+Shift+q" = "kill";
        "${super}+d" = "exec ${menu}";

        "${super}+${left}" = "focus left";
        "${super}+${down}" = "focus down";
        "${super}+${up}" = "focus up";
        "${super}+${right}" = "focus right";

        "${super}+Left" = "focus left";
        "${super}+Down" = "focus down";
        "${super}+Up" = "focus up";
        "${super}+Right" = "focus right";

        "${super}+Shift+${left}" = "move left";
        "${super}+Shift+${down}" = "move down";
        "${super}+Shift+${up}" = "move up";
        "${super}+Shift+${right}" = "move right";

        "${super}+Shift+Left" = "move left";
        "${super}+Shift+Down" = "move down";
        "${super}+Shift+Up" = "move up";
        "${super}+Shift+Right" = "move right";

        "${super}+b" = "splith";
        "${super}+v" = "splitv";
        "${super}+a" = "focus parent";

        "${super}+s" = "layout stacking";
        "${super}+w" = "layout tabbed";
        "${super}+e" = "layout toggle split";

        "${super}+Shift+space" = "floating toggle";
        "${super}+space" = "focus mode_toggle";

        "${super}+1" = "workspace number 1";
        "${super}+2" = "workspace number 2";
        "${super}+3" = "workspace number 3";
        "${super}+4" = "workspace number 4";
        "${super}+5" = "workspace number 5";
        "${super}+6" = "workspace number 6";
        "${super}+7" = "workspace number 7";
        "${super}+8" = "workspace number 8";
        "${super}+9" = "workspace number 9";
        "${super}+0" = "workspace number 10";

        "${super}+Shift+1" = "move container to workspace number 1";
        "${super}+Shift+2" = "move container to workspace number 2";
        "${super}+Shift+3" = "move container to workspace number 3";
        "${super}+Shift+4" = "move container to workspace number 4";
        "${super}+Shift+5" = "move container to workspace number 5";
        "${super}+Shift+6" = "move container to workspace number 6";
        "${super}+Shift+7" = "move container to workspace number 7";
        "${super}+Shift+8" = "move container to workspace number 8";
        "${super}+Shift+9" = "move container to workspace number 9";
        "${super}+Shift+0" = "move container to workspace number 10";

        "${super}+Shift+minus" = "move scratchpad";
        "${super}+minus" = "scratchpad show";

        "${super}+Shift+c" = "reload";
        "${super}+Shift+e" =
          "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";

        "${super}+r" = "mode resize";
        "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
        "XF86AudioMicMute" = "exec pactl set-source-mute @DEFAULT_SOURCE@ toggle";
        "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
        "XF86MonBrightnessUp" = "exec brightnessctl set 5%+";
        "XF86AudioPlay" = "exec playerctl play-pause";
        "XF86AudioPause" = "exec playerctl play-pause";
        "XF86AudioNext" = "exec playerctl next";
        "XF86AudioPrev" = "exec playerctl previous";
        "XF86AudioStop" = "exec playerctl stop";
        # thinkpad hack
        "XF86NotificationCenter" = "exec playerctl stop";
        "XF86HangupPhone" = "exec playerctl play-pause";
        "XF86Favorites" = "exec playerctl next";
        "XF86PickupPhone" = "exec playerctl previous";
        "Print" = "exec flameshot gui";
        "${super}+G" = "mode game";
#       "${modifier}+Return" = "exec ${pkgs.foot}/bin/foot";
      };
      modifier = "${super}";
      terminal = "alacritty";
      menu = "rofi -modes drun -show drun";
      bars = [
        {command = "waybar";}
      ];
    };
  };
}

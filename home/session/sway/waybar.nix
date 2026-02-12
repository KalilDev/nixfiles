{config, lib, pkgs, ...}: {
  imports = [
    ./wlogout.nix
  ];
home.packages = with pkgs; [
    waybar
    bc
];
programs.waybar = {
    enable = true;
    settings.waybar = {
        height = 32;
        spacing = 8;
        modules-left = [
            "sway/workspaces"
            "hyprland/workspaces"
            "sway/mode"
            "sway/scratchpad"
            "clock"
            "cpu"
            "memory"
            "temperature"
    "custom/tdp"
            "power-profiles-daemon"
        ];
        modules-center = [
            "sway/window"
        ];
        modules-right = [
            "custom/updates"
            "pulseaudio"
            "network"
            "battery"
            "custom/battery_consumption"
            "tray"
            "idle_inhibitor"
            "custom/power"
        ];
        margin-top = 2;
        margin-bottom = 2;
        margin-right = 4;
        margin-left = 4;
        power-profiles-daemon = {
            format = "{profile} {icon}";
            tooltip-format = "Power profile: {profile}\nDriver: {driver}";
            tooltip = true;
            format-icons = {
                default = "";
                performance = "";
                balanced = "";
                power-save = "";
            };
        };
        "sway/workspaces" = {
            disable-scroll = true;
            all-outputs = false;
            format = " {icon} {name} ";
            format-icons = {
                urgent = "";
                focused = "";
                default = "";
            };
        };
        "hyprland/workspaces" = {
            disable-scroll = true;
            all-outputs = false;
            format = " {icon} {name} ";
            format-icons = {
                urgent = "";
                focused = "";
                default = "";
           };
        };
        "sway/mode" = {
            format = "<span style=\"italic\">{}</span>";
        };
        tray = {
            spacing = 10;
        };
        clock = {
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            format-alt = "{:%a %d of %B (%d/%m/%y)}";
        };
        cpu = {
            format = "{usage}% ";
        };
        memory = {
            format = "{}% ";
        };
        battery = {
            bat = "BAT0";
            states = {
                warning = 20;
                critical = 10;
            };
            format = "{capacity}% {icon}";
            format-icons = [
                ""
                ""
                ""
                ""
                ""
            ];
            interval = 20;
        };
        network = {
            format-wifi = "{essid} ";
            format-ethernet = "{ifname} ";
            format-disconnected = "Disconnected ";
            tooltip-format = "{ifname} via {gwaddr} ";
            format-linked = "{ifname} (No IP) ";
            format-alt = "{ifname}: {ipaddr}/{cidr}";
        };
        pulseaudio = {
            format = "{volume}% {icon}";
            format-bluetooth = "{volume}% {icon}";
            format-muted = "OFF ";
            format-icons = {
            headphones = "";
            handsfree = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [
                ""
                ""
            ];
            };
            on-click = "pwvucontrol";
        };
        idle_inhibitor = {
            format = " {icon} ";
            format-icons = {
                activated = "";
                deactivated = "";
            };
        };
        "custom/power" = {
            format = "  ";
            on-click = "wlogout";
            tooltip = false;
        };
        "custom/tdp" = {
            format = "{}w ";
            interval = 3;
            escape = true;
            exec = "echo \"$(cat \/sys\/devices\/pci0000:00\/0000:00:08.1\/0000:08:00.0\/hwmon\/hwmon*\/power1_input) \/ 1000000\" | bc -l | sed -E \"s\/^([0-9]+)\\.[0-9].*\/\\1\/g\"";
        };
        "custom/battery_consumption" = {
            format = "{}w";
            interval = 3;
            escape = true;
            exec = "echo \"$(cat /sys/class/power_supply/BAT0/power_now) / 1000000\" | bc -l | sed -E \"s/^([0-9]+\\.?[0-9]?)[0-9]*/\\1/g\""; 
        };
    };
    style = ''
        * {
            border-radius: 4px;
            font-size: 13px;
            font-family: "monospace", "Fira Code", "Fira Code Symbols", "Font Awesome 6", "Font Awesome",  sans-serif;
            font-family: 'monospace';
            min-height: 0;
            text-shadow: none;
        }

        window#waybar {
            background: #ba68c8;
            color: rgba(0,0,0,0.8);
            border-radius: 8px;
        }

        #window {
            font-weight: bold;
            font-family: 'sans-serif';
        }

        #workspaces button {
            padding: 5px;
            background: transparent;
            transition: all;
            transition-duration: 200ms;
            border: 2px solid transparent;
            color: rgba(0,0,0,0.8);
        }

        #workspaces button:hover {
            background: rgba(136, 57, 151, 0.4);
            border: 2px solid #ee98fb;
            border-radius: 8px;
        }

        #workspaces button.focused {
            color:  #6A1B9A;
            border: 2px solid transparent;
            border-right: 2px solid  #6A1B9A;
        }
        #workspaces button.focused:hover {
            border: 2px solid transparent;
            border-right: 2px solid #6A1B9A;
            border-radius: 8px;
        }

        #mode {
            background: #ee98fb;
            color: rgba(0,0,0,0.87);
            border-bottom: 3px solid #953977;
        }

        #clock, #battery, #cpu, #memory, #network, #pulseaudio, #custom-updates, #custom-spotify, #tray, #mode {
            padding: 0 5px;
            margin: 0 2px;
        }


        #clock {
            font-weight: bold;
        }

        #battery {
        }

        #battery icon {
            color: #a53127;
        }

        #battery.charging {
        }

        @keyframes blink {
            to {
                background-color: #ffffff;
                color: black;
            }
        }

        #battery.warning:not(.charging) {
            color: white;
            animation-name: blink;
            animation-duration: 0.5s;
            animation-timing-function: linear;
            animation-iteration-count: infinite;
            animation-direction: alternate;
        }

        #battery.critical:not(.charging) {
            color: white;
            background: #a53127;
            animation-name: blink;
            animation-duration: 0.5s;
            animation-timing-function: linear;
            animation-iteration-count: infinite;
            animation-direction: alternate;
        }

        #cpu {
        }

        #memory {
        }

        #network {
        }

        #network.disconnected {
            background: #a53127;
        }

        #pulseaudio {
        }

        #pulseaudio.muted {
        }

        #custom-updates {
        }

        #tray {
        }
    '';
  };
}

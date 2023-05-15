{ lib, config, pkgs, ... }:

{
  fonts.fonts = [ pkgs.roboto ];

  home-manager.users."${config.vars.username}" = {
    programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          modules-left = [ "sway/workspaces" "sway/mode" "custom/media" ];
          modules-right = lib.mkDefault [ "tray" "network" "pulseaudio" "backlight" "clock" ];
          "sway/workspaces" = {
            disable-scroll = true;
            format = "{name}";
            format-icons = {
              "spotify" = "";
            };
          };
          "sway/mode" = { format = "{}"; };
          "custom/media" = {
            format = "{icon} {}";
            return-type = "json";
            max-length = 40;
            format-icons = {
              spotify = "";
              default = "";
            };
            escape = true;
            on-click = "playerctl --player='spotify,any' play-pause";
            exec = "waybar-mediaplayer.py --player spotify 2> /dev/null";
          };
          tray = { icon-size = 18; spacing = 10; };
          pulseaudio = {
            # "scroll-step" = 1 // % can be a float;
            format = "{icon} {volume}% {format_source}";
            format-bluetooth = "{volume}% {icon} {format_source}";
            format-bluetooth-muted = "󰝟 {icon} {format_source}";
            format-muted = "󰝟 {format_source}";
            format-source = " {volume}%";
            format-source-muted = "";
            format-icons = {
              headphones = "";
              handsfree = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = [ " " " " " " ];
            };
            on-click = "pavucontrol";
          };
          backlight = {
            format = "{icon} {percent}%";
            format-icons = [ "" ];
          };
          battery = {
            states = {
              good = 70;
              warning = 25;
              critical = 10;
            };
            format = "{icon} {capacity}%";
            format-charging = "  {capacity}%";
            format-plugged = "  {capacity}%";
            format-alt = "{icon} {time}";
            format-time = "{H}h{M}";
            format-icons = [ " " " " " " " " " " ];
          };
          clock = {
            interval = 1;
            format = "{:%B %d, %H:%M}";
            tooltip = true;
            tooltip-format = "{:%H:%M:%S}";
          };
          network = {
            format-wifi = "{essid} ({signalStrength}%) ";
            format-ethernet = "Ethernet ";
            format-linked = "Ethernet (No IP) ";
            format-disconnected = "Disconnected ";
            format-alt = " {bandwidthDownBits}  {bandwidthUpBits}";
          };
        };
      };

      style = builtins.readFile ./style.css;
    };
  };
}

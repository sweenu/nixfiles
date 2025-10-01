{
  self,
  config,
  pkgs,
  ...
}:
let
  wallpapersDir = "${config.vars.home}/${config.vars.picturesFolder}/wallpapers";
in
{
  home-manager.users."${config.vars.username}" = {
    programs.caelestia = {
      enable = true;
      settings = {
        general = {
          apps = {
            terminal = config.vars.terminalBin;
            audio = "${pkgs.pwvucontrol}/bin/pwvucontrol";
          };
          idle = {
            timeouts = [
              {
                timeout = 300; # 5 minutes
                idleAction = "lock";
              }
            ];
          };
        };
        bar = {
          status = {
            showAudio = true;
          };
          workspaces = rec {
            shown = 4;
            label = "";
            showWindowsOnSpecialWorkspaces = false;
            occupiedLabel = "";
            activeLabel = occupiedLabel;
          };
          tray = {
            background = true;
            iconSubs = [
              {
                id = "spotify-client";
                image = "${self}/assets/spotify-light.svg";
              }
            ];
          };
          clock.showIcon = false;
          entries = [
            {
              id = "logo";
              enabled = false;
            }
            {
              id = "workspaces";
              enabled = true;
            }
            {
              id = "spacer";
              enabled = true;
            }
            {
              id = "activeWindow";
              enabled = true;
            }
            {
              id = "spacer";
              enabled = true;
            }
            {
              id = "tray";
              enabled = true;
            }
            {
              id = "clock";
              enabled = true;
            }
            {
              id = "statusIcons";
              enabled = true;
            }
            {
              id = "power";
              enabled = false;
            }
          ];
        };
        background = {
          enabled = true;
          desktopClock.enabled = false;
          visualiser.enabled = false;
        };
        services = {
          useFahrenheit = false;
          useTwelveHourClock = false;
        };
        session = {
          vimKeybinds = true;
        };
        launcher = {
          actionPrefix = "/";
          vimKeybinds = true;
        };
        paths = {
          wallpaperDir = wallpapersDir;
          sessionGif = "${self}/assets/bird.gif";
          # mediaGif = "${self}/assets/.gif";
        };
        utilities = {
          enabled = true;
        };
      };
      cli.enable = true;
    };

    wayland.windowManager.hyprland.settings.env = [
      "CAELESTIA_WALLPAPERS_DIR, ${wallpapersDir}"
      "CAELESTIA_SCREENSHOTS_DIR, ${config.vars.home}/${config.vars.screenshotFolder}"
      "CAELESTIA_RECORDINGS_DIR, ${config.vars.home}/${config.vars.screencastFolder}"
    ];

    # Use caelestia's dynamically generated theme in the terminal
    programs.fish.interactiveShellInit = ''
      cat ~/.local/state/caelestia/sequences.txt 2> /dev/null
    '';
  };
}

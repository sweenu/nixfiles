{
  config,
  ...
}:
{
  home-manager.users."${config.vars.username}".services.shikane = {
    enable = true;
    settings = {
      profile =
        let
          resWidth = 2256;
          resHeight = 1504;
          laptopScale = 1.6;
          dellWidth = 3840;
          dellHeight = 2160;
          dellScale = 1.5;
          laptopOutput = {
            search = "n=eDP-1";
            enable = true;
            mode = {
              width = resWidth;
              height = resHeight;
              refresh = 60;
            };
            scale = laptopScale;
          };
        in
        [
          {
            name = "laptop-only";
            output = [ laptopOutput ];
          }
          # An external monitor to the right; Hyprland places the "asdf"
          # workspaces on it (see hypr-workspace-monitor).
          {
            name = "external-output-default";
            output = [
              {
                search = "n/(DP-[1-9]|HDMI-[A-C]-[1-9])";
                enable = true;
                position = {
                  x = builtins.floor (resWidth / laptopScale);
                  y = 0;
                };
                mode = "preferred";
              }
              (
                laptopOutput
                // {
                  position = {
                    x = 0;
                    y = 0;
                  };
                }
              )
            ];
          }
          # At home, put the laptop to the right of the Dell.
          {
            name = "home";
            output = [
              {
                search = [
                  "v=Dell Inc."
                  "m=DELL U3225QE"
                  "s=86D0G84"
                ];
                enable = true;
                position = {
                  x = 0;
                  y = 0;
                };
                mode = {
                  width = dellWidth;
                  height = dellHeight;
                  refresh = 60;
                };
                scale = dellScale;
              }
              (
                laptopOutput
                // {
                  position = {
                    x = builtins.floor (dellWidth / dellScale);
                    # Align bottom corners
                    y = builtins.floor (dellHeight / dellScale - resHeight / laptopScale);
                  };
                }
              )
            ];
          }
        ];
    };
  };
}

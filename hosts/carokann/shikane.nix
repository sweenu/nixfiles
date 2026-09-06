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
          laptopOutput = {
            search = "n=eDP-1";
            enable = true;
            mode = {
              width = resWidth;
              height = resHeight;
              refresh = 60;
            };
            scale = 1.6;
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
                  x = resWidth;
                  y = 0;
                };
                mode = "preferred";
              }
              laptopOutput
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
                  width = 3840;
                  height = 2160;
                  refresh = 60;
                };
                scale = 1.5;
              }
              (
                laptopOutput
                // {
                  position = {
                    x = 2560; # 3840 / 1.5
                    y = 500; # Align bottom corners: 2160/1.5 - 1504/1.6
                  };
                }
              )
            ];
          }
        ];
    };
  };
}

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
                  "m=DELL U2424HE"
                  "s=FF904X3"
                ];
                enable = true;
                position = {
                  x = 0;
                  y = 0;
                };
                mode = "1920x1080";
              }
              (
                laptopOutput
                // {
                  position = {
                    x = 1920;
                    y = 141;
                  }; # Align bottom corners
                }
              )
            ];
          }
        ];
    };
  };
}

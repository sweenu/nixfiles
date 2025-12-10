{
  config,
  lib,
  pkgs,
  ...
}:
let
  shikaneMonitorSetup = pkgs.writeShellScriptBin "shikane-monitor-setup" ''
    MONITOR="$1"
    START="$2"
    END="$3"

    # Wait until the monitor is actually listed by Hyprland
    # giving up after 5 seconds to prevent infinite hanging
    MAX_RETRIES=50
    i=0
    while ! hyprctl monitors -j | ${lib.getExe pkgs.jq} -e ".[] | select(.name == \"$MONITOR\")" > /dev/null; do
        if [ $i -ge $MAX_RETRIES ]; then
            echo "Timeout waiting for monitor $MONITOR"
            exit 1
        fi
        sleep 0.1
        ((i++))
    done

    # Small buffer after detection to allow layout to settle
    sleep 0.2

    # Apply the rule for future workspaces
    # This ensures any NEW workspaces in this range open on this monitor
    hyprctl keyword workspace "r[$START-$END],monitor:$MONITOR"

    # Force-move existing persistent workspaces
    for ((i=START; i<=END; i++)); do
      hyprctl dispatch moveworkspacetomonitor "$i" "$MONITOR"
    done
  '';
in
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
          # Put a default external monitor to the right and assign workspaces u, i, o and p.
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
                exec = [
                  "${lib.getExe shikaneMonitorSetup} \"$SHIKANE_OUTPUT_NAME\" 5 8"
                ];
              }
              (laptopOutput // { exec = [ "hyprctl keyword workspace r[1-4],monitor:$SHIKANE_OUTPUT_NAME" ]; })
            ];
          }
          # At home, put laptop monitor on the right and give the main monitor a, s, d and f
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
                exec = [
                  "${lib.getExe shikaneMonitorSetup} \"$SHIKANE_OUTPUT_NAME\" 1 4"
                ];
              }
              (
                laptopOutput
                // {
                  position = {
                    x = 1920;
                    y = 141;
                  }; # Align bottom corners
                  exec = [
                    "${lib.getExe shikaneMonitorSetup} \"$SHIKANE_OUTPUT_NAME\" 5 8"
                  ];
                }
              )
            ];
          }
        ];
    };
  };
}

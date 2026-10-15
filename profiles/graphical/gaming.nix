{ pkgs, ... }:

{
  programs = {
    steam.enable = true;

    gamescope = {
      enable = true;
      # Must stay off while gamescope is invoked from Steam launch options.
      # capSysNice routes it through security.wrappers, and Steam's FHS env
      # runs under bubblewrap, which sets PR_SET_NO_NEW_PRIVS: execve then
      # refuses to grant file capabilities, the wrapper's capset() gets EPERM,
      # and wrapper.c aborts with "failed to inherit capabilities" before ever
      # exec'ing gamescope. The game simply never starts.
      #
      # The cost is gamescope compositing at normal thread priority ("No
      # CAP_SYS_NICE, falling back to regular-priority compute and threads"),
      # which is a far smaller loss than the resolution scaling it buys.
      capSysNice = false;

      # gamescope's nested Wayland backend desyncs buffer releases against
      # Hyprland 0.55 ("xdg_backend: Compositor released us but we were not
      # acquired"), after which it stops presenting and the game renders
      # black, flashing a single frame whenever something forces a repaint.
      # The game itself is fine throughout — gamescope's own focus_info shows
      # it correctly focused. The SDL backend does not use xdg_backend at all,
      # so the failure cannot occur. Retry the default once Hyprland or
      # gamescope moves on.
      args = [
        "--backend"
        "sdl"
      ];
    };

    gamemode = {
      enable = true;
      settings.general = {
        igpu_desiredgov = "powersave";
        igpu_power_threshold = 0.3;
      };
    };
  };

  environment.defaultPackages = with pkgs; [ mangohud ];

  boot.kernelModules = [ "ntsync" ];
}

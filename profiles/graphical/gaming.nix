{ pkgs, inputs, ... }:

{
  imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

  services.flatpak = {
    enable = true;
    # The GeForce NOW runtime comes from flathub, so it must stay listed.
    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
      {
        name = "GeForceNOW";
        location = "https://international.download.nvidia.com/GFNLinux/flatpak/geforcenow.flatpakrepo";
      }
    ];
    packages = [
      {
        appId = "com.nvidia.geforcenow";
        origin = "GeForceNOW";
      }
    ];
    # On Wayland, SDL2 renders at 1x and Hyprland upscales it, which is blurry. Through
    # XWayland with force_zero_scaling the image is sharp, but the UI is smaller.
    overrides."com.nvidia.geforcenow".Environment.SDL_VIDEODRIVER = "x11";
  };

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

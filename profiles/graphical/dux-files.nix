{ inputs, ... }:

{
  imports = [ inputs.dux-files.nixosModules.default ];

  programs.dux-files = {
    enable = true;
    # The FileChooser portal and FileManager1 both need dfiles already running.
    systemd.enable = true;
    # NixOS module, not home-manager: hyprland owns the live portal, and polkit
    # only finds dfiles policy via systemPackages.
    portal = {
      enable = true;
      preferred = true;
    };
  };
}

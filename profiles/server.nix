{ config, ... }:

{
  imports = [ ./core/tailscale.nix ];

  documentation.enable = false;

  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 5d";
    };
    optimise.automatic = true;
  };

  programs.mosh.enable = true;

  services = {
    openssh = {
      enable = true;
      openFirewall = false;
      settings.PasswordAuthentication = false;
    };
    tailscale.enable = true;
  };

  users.users.root.openssh.authorizedKeys.keys = [ config.vars.sshPublicKey ];
}

{ config, ... }:

{
  imports = [ ./core/tailscale.nix ];

  documentation.enable = false;

  nix = {
    gc.automatic = true;
    optimise.automatic = true;
  };

  programs.mosh.enable = true;

  services = {
    openssh = {
      enable = true;
      passwordAuthentication = false;
    };
    tailscale.enable = true;
  };

  users.users.root.openssh.authorizedKeys.keys = [ config.vars.sshPublicKey ];
}

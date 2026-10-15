{ config, ... }:
{
  hifiberry = {
    enable = true;
    soundcard = "hifiberry-dacplus-std"; # DAC+ / Amp2

    setup = {
      skipWizard = true;
      webAuth = {
        protection = "risky";
        hashedPassword = "$argon2id$v=19$m=65536,t=3,p=4$iEYj2ze7RjCNMuHOCJuvfA$H3NgEHkb9lgqVc+zdlvwWK4lkDhvzrbkjo5Lbjeqs1I";
      };
    };

    roomeq.enable = false;
    dsp.enable = false;
    bleProvisioning.enable = false;
  };

  # These hosts are built by hifiberry-nixos' own nixosSystem rather than mkHost,
  # so they miss the allowUnfree that mkHost sets. suites.common turns on
  # hardware.enableAllFirmware, which pulls in unfree Broadcom firmware.
  nixpkgs.config.allowUnfree = true;

  users.users.hifiberry.hashedPassword = "$y$j9T$ZjVM7P34OZjC8/o5LI5N7/$nFGR9tfv6TDeIrf7FZ.o5Kb.WJuewOB6THeNBIuY44/";

  # The player user for SSH, root for deploy-rs.
  users.users.hifiberry.openssh.authorizedKeys.keys = [ config.vars.sshPublicKey ];
  users.users.root.openssh.authorizedKeys.keys = [ config.vars.sshPublicKey ];
}

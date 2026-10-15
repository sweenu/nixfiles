# Bedroom speakers: a Raspberry Pi 4 with a HiFiBerry DAC+ / Amp2, playing
# Music Assistant through Sendspin. HiFiBerryOS on NixOS, from
# github:sweenu/hifiberry-nixos (see its README for the hifiberry.* options).
#
# First install: build the SD card image and flash it
#   nix build .#nixosConfigurations.bedroom-speakers.config.system.build.sdImage
# then deploy as usual: deploy .#bedroom-speakers
{ config, suites, ... }:
{
  imports = suites.common;

  hifiberry = {
    enable = true;
    soundcard = "hifiberry-dacplus-std"; # DAC+ / Amp2

    # What the web interface's setup wizard would ask.
    setup = {
      skipWizard = true;
      systemName = "Bedroom speakers"; # hostname bedroom-speakers
    };

    # A Sendspin receiver: leave out what it does not use.
    roomeq.enable = false; # room measurement and correction
    dsp.enable = false; # only for HiFiBerry DSP boards
    bleProvisioning.enable = false; # Wi-Fi setup over Bluetooth LE
  };

  # The player user for SSH, root for deploy-rs.
  users.users.hifiberry.openssh.authorizedKeys.keys = [ config.vars.sshPublicKey ];
  users.users.root.openssh.authorizedKeys.keys = [ config.vars.sshPublicKey ];
}

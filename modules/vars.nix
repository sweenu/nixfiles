{ lib, ... }:

with lib;
with lib.types;
{
  options.vars = {
    email = mkOption { type = str; };
    username = mkOption { type = str; };
    terminal = mkOption { type = str; };
    terminalBin = mkOption { type = str; };
    defaultBrowser = mkOption { type = str; };

    home = mkOption { type = str; };
    configHome = mkOption { type = str; };
    documentsFolder = mkOption { type = str; };
    downloadFolder = mkOption { type = str; };
    musicFolder = mkOption { type = str; };
    picturesFolder = mkOption { type = str; };
    videosFolder = mkOption { type = str; };
    repositoriesFolder = mkOption { type = str; };
    screenshotFolder = mkOption { type = str; };
    screencastFolder = mkOption { type = str; };
    wallpapersFolder = mkOption { type = str; };
    defaultFont = mkOption {
      type = submodule {
        options = {
          name = mkOption { type = str; };
          package = mkOption { type = package; };
        };
      };
    };
    defaultMonoFont = mkOption {
      type = submodule {
        options = {
          name = mkOption { type = str; };
          package = mkOption { type = package; };
        };
      };
    };

    sshPublicKey = mkOption { type = str; };

    timezone = mkOption { type = str; };

    # Server vars
    domainName = mkOption { type = str; };
    smtpUsername = mkOption { type = str; };
    smtpHost = mkOption { type = str; };
    smtpPort = mkOption { type = int; };

    # RaspberryPi vars
    grunfeldIPv4 = mkOption { type = str; };
  };
}

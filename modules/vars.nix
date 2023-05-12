{ lib, ... }:

with lib;

{
  options.vars = {
    email = mkOption { type = types.str; };
    username = mkOption { type = types.str; };
    terminal = mkOption { type = types.str; };
    terminalBin = mkOption { type = types.str; };

    home = mkOption { type = types.str; };
    configHome = mkOption { type = types.str; };
    documentsFolder = mkOption { type = types.str; };
    downloadFolder = mkOption { type = types.str; };
    musicFolder = mkOption { type = types.str; };
    picturesFolder = mkOption { type = types.str; };
    videosFolder = mkOption { type = types.str; };
    repositoriesFolder = mkOption { type = types.str; };
    screenshotFolder = mkOption { type = types.str; };
    screencastFolder = mkOption { type = types.str; };
    wallpaper = mkOption { type = types.str; };
    defaultFont = mkOption { type = types.str; };
    defaultMonoFont = mkOption { type = types.str; };

    sshPublicKey = mkOption { type = types.str; };

    timezone = mkOption { type = types.str; };

    # Server vars
    domainName = mkOption { type = types.str; };
    smtpUsername = mkOption { type = types.str; };
    smtpHost = mkOption { type = types.str; };
    smtpPort = mkOption { type = types.int; };

    # RaspberryPi vars
    grunfeldIPv4 = mkOption { type = types.str; };
  };
}

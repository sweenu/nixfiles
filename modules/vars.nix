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

    dnsResolvers = mkOption { type = listOf str; };

    # Server vars
    defaultGateway = mkOption { type = str; };
    staticIPWithSubnet = mkOption { type = str; };
    staticIP = mkOption { type = str; };

    lanSubnet = mkOption { type = str; };
    domainName = mkOption { type = str; };
    tailnetName = mkOption { type = str; };
    smtp = mkOption {
      type = submodule {
        options = {
          user = mkOption { type = str; };
          host = mkOption { type = str; };
          port = mkOption { type = int; };
        };
      };
    };
  };
}

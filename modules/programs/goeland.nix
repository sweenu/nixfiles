{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.goeland;
  tomlFormat = pkgs.formats.toml { };
in
{
  meta.maintainers = with maintainers; [ sweenu ];

  options.programs.goeland = {
    enable = mkEnableOption (mdDoc "goeland");

    settings = mkOption {
      description = mdDoc ''
        Configuration of goeland.
        See the [example config file](https://github.com/slurdge/goeland/blob/master/cmd/asset/config.default.toml) for the available options.
      '';
      default = { };
      type = types.submodule {
        freeformType = tomlFormat.type;
      };
    };
    interval = mkOption {
      type = types.str;
      default = "12h";
      description = mdDoc "How often to check the feeds, in systemd interval format";
    };
  };

  config = mkIf cfg.enable {
    programs.goeland.settings.database = mkDefault "/var/lib/goeland/goeland.db";

    environment.systemPackages = [ pkgs.goeland ];

    systemd.timers.goeland = {
      partOf = [ "goeland.service" ];
      wantedBy = [ "timers.target" ];
      timerConfig.OnBootSec = "0";
      timerConfig.OnUnitActiveSec = cfg.interval;
    };

    systemd.services.goeland =
      let

        confFile = tomlFormat.generate "config.toml" cfg.settings;
      in
      {
        serviceConfig = {
          ExecStart = "${pkgs.goeland}/bin/goeland run -c ${confFile}";
          User = "goeland";
        };
      };

    users.users.goeland = {
      description = "goeland user";
      uid = 326;
      group = "goeland";
    };
    users.groups.goeland.gid = 326;
  };
}

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.bluetuith;
  jsonFormat = pkgs.formats.json { };
in
{
  options.programs.bluetuith = {
    enable = mkEnableOption "A TUI bluetooth manager for Linux.";

    settings = mkOption {
      description = ''
        Configuration of bluetuith.
        See [the docs](https://darkhz.github.io/bluetuith/Configuration.html) for available options.
      '';
      default = { };
      type = jsonFormat.type;
    };
  };

  config = mkIf cfg.enable {
    home-manager.users."${config.vars.username}" = {
      home.packages = [ pkgs.bluetuith ];

      xdg.configFile."bluetuith/bluetuith.conf" = mkIf (cfg.settings != { }) {
        source = jsonFormat.generate "bluetuith.conf" cfg.settings;
      };
    };
  };

  meta.maintainers = [ maintainers.sweenu ];
}

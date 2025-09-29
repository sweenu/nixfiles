{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.glow;
  ymlFormat = pkgs.formats.yaml { };
in
{
  options.programs.glow = {
    enable = mkEnableOption "Render markdown on the CLI, with pizzazz!";

    settings = mkOption {
      description = "Configuration of glow.";
      default = { };
      type = ymlFormat.type;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.glow ];

    xdg.configFile."glow/glow.yml" = mkIf (cfg.settings != { }) {
      source = ymlFormat.generate "glow.yml" cfg.settings;
    };
  };

  meta.maintainers = [ maintainers.sweenu ];
}

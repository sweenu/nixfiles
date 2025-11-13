{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    types
    ;

  cfg = config.programs.beeper;
  jsonFormat = pkgs.formats.json { };
  json5 = pkgs.python3Packages.toPythonApplication pkgs.python3Packages.json5;

  impureConfigMerger = empty: jqOperation: path: staticSettings: ''
    mkdir -p $(dirname ${lib.escapeShellArg path})
    if [ ! -e ${lib.escapeShellArg path} ]; then
      # No file? Create it
      echo ${lib.escapeShellArg empty} > ${lib.escapeShellArg path}
    fi
    dynamic="$(${lib.getExe json5} --as-json ${lib.escapeShellArg path} 2>/dev/null || echo ${lib.escapeShellArg empty})"
    static="$(cat ${lib.escapeShellArg staticSettings})"
    config="$(${lib.getExe pkgs.jq} -n ${lib.escapeShellArg jqOperation} --argjson dynamic "$dynamic" --argjson static "$static")"
    printf '%s\n' "$config" > ${lib.escapeShellArg path}
    unset config
  '';

in
{
  options.programs.beeper = {
    enable = mkEnableOption "Beeper messaging client";

    package = mkPackageOption pkgs "beeper" { nullable = true; };

    settings = mkOption {
      type = jsonFormat.type;
      default = { };
      description = "Beeper configuration as a Nix attribute set";
    };

    mergeWithExisting = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to merge with existing config file if it exists";
    };

    overrideOnConflict = mkOption {
      type = types.bool;
      default = false;
      description = "Override existing config file instead of erroring on merge conflicts";
    };
  };

  config = mkIf cfg.enable {
    home.packages = mkIf (cfg.package != null) [ cfg.package ];

    home.activation = lib.mkIf (cfg.mergeWithExisting && cfg.settings != { }) {
      beeperConfigActivation = lib.hm.dag.entryAfter [ "linkGeneration" ] (
        let
          jqOperation =
            if cfg.overrideOnConflict then
              "$dynamic * $static"
            else
              # Check for conflicts and error if any
              ''
                $dynamic as $d | $static as $s |
                if ($d | keys | map(select($s[.] != null and $s[.] != $d[.])) | length) > 0 then
                  error("Beeper config merge conflicts detected. Set overrideOnConflict = true to override conflicts.")
                else
                  $d * $s
                end
              '';
        in
        impureConfigMerger "{}" jqOperation "${config.xdg.configHome}/BeeperTexts/config.json" (
          jsonFormat.generate "beeper-settings" cfg.settings
        )
      );
    };

    xdg.configFile = lib.mkIf (!cfg.mergeWithExisting && cfg.settings != { }) {
      "BeeperTexts/config.json".source = jsonFormat.generate "beeper-settings" cfg.settings;
    };
  };

  meta.maintainers = [ lib.hm.maintainers.sweenu ];
}

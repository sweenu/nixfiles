final: prev: with prev; {
  fedit = writeShellApplication {
    name = "fedit";
    text = (builtins.readFile ./fedit.sh);
    runtimeInputs = [
      fd
      skim
      bat
      git
    ];
  };

  dms-settings = writeShellApplication {
    name = "dms-settings";
    text = (builtins.readFile ./dms-settings.sh);
    runtimeInputs = [ jq ];
  };

  kakounePlugins = kakounePlugins // lib.recurseIntoAttrs (callPackage ./kakoune_plugins.nix { });

  backlight = writers.writePython3Bin "backlight" { } (builtins.readFile ./backlight.py);

  aiobbox = pkgs.python314Packages.callPackage ./aiobbox.nix { };
  bbox = callPackage ./bbox.nix { };

  dawarich-api = pkgs.python314Packages.callPackage ./dawarich-api.nix { };
  dawarich-ha = callPackage ./dawarich-ha.nix { };

  journal-brief = callPackage ./journal-brief.nix { };

  n8n = prev.n8n.overrideAttrs (oldAttrs: {
    NODE_OPTIONS = lib.concatStringsSep " " (
      lib.filter (v: v != "") [
        (oldAttrs.NODE_OPTIONS or "")
        "--max-old-space-size=8192"
      ]
    );
  });
}

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

  kakounePlugins = kakounePlugins // lib.recurseIntoAttrs (callPackage ./kakoune_plugins.nix { });

  backlight = writers.writePython3Bin "backlight" { } (builtins.readFile ./backlight.py);

  aiobbox = pkgs.python314Packages.callPackage ./aiobbox.nix { };
  bbox = callPackage ./bbox.nix { };

  dawarich-api = pkgs.python314Packages.callPackage ./dawarich-api.nix { };
  dawarich-ha = callPackage ./dawarich-ha.nix { };

  openthread-border-router = prev.openthread-border-router.overrideAttrs (oldAttrs: {
    postFixup = lib.concatStringsSep "\n" [
      (oldAttrs.postFixup or "")
      ''
        substituteInPlace $out/bin/otbr-firewall \
          --replace-fail '#!/bin/bash' '#!${bash}/bin/bash'
      ''
    ];
  });

  openai-whisper-cloud = callPackage ./openai-whisper-cloud.nix { };
}

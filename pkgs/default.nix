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

  soundcards = writers.writeBashBin "soundcards" {
    makeWrapperArgs = [
      "--prefix"
      "PATH"
      ":"
      "${lib.makeBinPath [
        pulseaudio
        wireplumber
      ]}"
    ];
  } (builtins.readFile ./soundcards.bash);

  backlight = writers.writePython3Bin "backlight" { } (builtins.readFile ./backlight.py);

  aiobbox = pkgs.python3Packages.callPackage ./aiobbox.nix { };
  bbox = callPackage ./bbox.nix { };

  dawarich-api = pkgs.python3Packages.callPackage ./dawarich-api.nix { };
  dawarich-ha = callPackage ./dawarich-ha.nix { };

  # Override python3Packages to include our custom aiosendspin
  python3Packages = prev.python3Packages.overrideScope (
    pyFinal: pyPrev: {
      aiosendspin = import ./aiosendspin.nix {
        inherit (prev) lib fetchPypi;
        buildPythonPackage = pyFinal.buildPythonPackage;
        inherit (pyFinal)
          setuptools
          aiohttp
          av
          mashumaro
          orjson
          pillow
          zeroconf
          ;
      };
    }
  );

  sendspin-cli = callPackage ./sendspin-cli.nix { };
}

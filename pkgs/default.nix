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
}

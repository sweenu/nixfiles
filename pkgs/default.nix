final: prev: with prev;
{
  fedit = writeShellApplication {
    name = "fedit";
    text = (builtins.readFile ./fedit.sh);
    runtimeInputs = [ fd skim bat git ];
  };

  kakounePlugins = kakounePlugins // recurseIntoAttrs (callPackage ./kakoune_plugins.nix { });
  soundcards = writers.writeBashBin "soundcards"
    {
      makeWrapperArgs = [
        "--prefix"
        "PATH"
        ":"
        "${lib.makeBinPath [ pulseaudio wireplumber ]}"
      ];
    }
    (builtins.readFile ./soundcards.bash);
  backlight = writers.writePython3Bin "backlight" { } (builtins.readFile ./backlight.py);
  inhibit = writeShellApplication {
    name = "inhibit";
    text = (builtins.readFile ./inhibit.sh);
    runtimeInputs = [ libnotify ];
  };
  capture = writeShellApplication {
    name = "capture";
    text = (builtins.readFile ./capture.sh);
    runtimeInputs = [ grim slurp swappy wf-recorder libnotify ];
  };
  choose-capture = writeShellApplication {
    name = "choose-capture";
    text = (builtins.readFile ./choose-capture.sh);
    runtimeInputs = [ wofi ];
  };
}

final: prev: with prev;
{
  fedit = writeShellApplication {
    name = "fedit";
    text = (builtins.readFile ./fedit.sh);
    runtimeInputs = [ fd skim bat git ];
  };

  kakounePlugins = kakounePlugins // recurseIntoAttrs (callPackage ./kakoune_plugins.nix { });

  # Used with sway keybindings
  sway-soundcards = writers.writeBashBin "sway-soundcards"
    {
      makeWrapperArgs = [
        "--prefix"
        "PATH"
        ":"
        "${lib.makeBinPath [ pulseaudio wireplumber ]}"
      ];
    }
    (builtins.readFile ./sway/soundcards.bash);
  sway-app-or-workspace = writeShellScriptBin "sway-app-or-workspace" (builtins.readFile ./sway/app_or_workspace.sh);
  sway-backlight = writers.writePython3Bin "sway-backlight" { } (builtins.readFile ./sway/backlight.py);
  sway-inhibit = writeShellApplication {
    name = "sway-inhibit";
    text = (builtins.readFile ./sway/inhibit.sh);
    runtimeInputs = [ libnotify ];
  };
  sway-capture = writeShellApplication {
    name = "sway-capture";
    text = (builtins.readFile ./sway/capture.sh);
    runtimeInputs = [ grim slurp swappy wf-recorder libnotify ];
  };
  sway-choose-capture = writeShellApplication {
    name = "sway-choose-capture";
    text = (builtins.readFile ./sway/choose-capture.sh);
    runtimeInputs = [ wofi ];
  };

  swaylock-fprintd = callPackage ./swaylock-fprintd.nix { };
}

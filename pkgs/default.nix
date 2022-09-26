final: prev: with prev;
{
  fedit = writeShellScriptBin "fedit" (builtins.readFile ./fedit.sh);
  kakounePlugins = kakounePlugins // recurseIntoAttrs (callPackage ./kakoune_plugins.nix { });

  # Used with sway keybindings
  sway-soundcards = writers.writeBashBin "sway-soundcards" (builtins.readFile ./sway/soundcards.bash);
  sway-app-or-workspace = writeShellScriptBin "sway-app-or-workspace" (builtins.readFile ./sway/app_or_workspace.sh);
  sway-inhibit = writeShellScriptBin "sway-inhibit" (builtins.readFile ./sway/inhibit.sh);
  sway-backlight = writers.writePython3Bin "sway-backlight" { } (builtins.readFile ./sway/backlight.py);
  sway-capture = writeShellScriptBin "sway-capture" (builtins.readFile ./sway/capture.sh);
  sway-choose-capture = writeShellScriptBin "sway-choose-capture" (builtins.readFile ./sway/choose-capture.sh);
}

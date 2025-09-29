{
  config,
  pkgs,
  inputs,
  ...
}:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in
{
  programs.spicetify = {
    enable = true;
    theme = spicePkgs.themes.dribbblish;
    # colorScheme = "nord-dark";
    enabledExtensions = with spicePkgs.extensions; [
      # Official
      shuffle
      loopyLoop
      keyboardShortcut
      popupLyrics
      bookmark
      fullAppDisplay
    ];

  };

  environment.defaultPackages = [
    config.programs.spicetify.spicetifyPackage
  ];
}

{ wallpaper }:

let
  transparent = "00000000";
  mainColor = "4a5568";
  mainColorTransparent = "${mainColor}4d";
  red = "e3574de6";
  yellow = "fac863e6";
in
{
  image = wallpaper;
  fingerprint = true;

  indicator-radius = 40;
  indicator-thickness = 30;

  inside-color = transparent;
  inside-clear-color = transparent;
  inside-caps-lock-color = transparent;
  inside-ver-color = transparent;
  inside-wrong-color = transparent;

  key-hl-color = mainColor;
  bs-hl-color = yellow;

  layout-bg-color = transparent;
  layout-border-color = transparent;
  layout-text-color = transparent;

  line-color = transparent;
  line-clear-color = transparent;
  line-caps-lock-color = transparent;
  line-ver-color = transparent;
  line-wrong-color = transparent;

  ring-color = mainColorTransparent;
  ring-clear-color = mainColorTransparent;
  ring-caps-lock-color = mainColorTransparent;
  ring-ver-color = mainColor;
  ring-wrong-color = red;

  separator-color = transparent;

  text-color = transparent;
  text-clear-color = transparent;
  text-caps-lock-color = transparent;
  text-ver-color = transparent;
  text-wrong-color = transparent;
}

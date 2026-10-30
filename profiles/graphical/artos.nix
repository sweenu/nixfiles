{
  pkgs,
  inputs,
  ...
}:

{
  environment.defaultPackages = [
    inputs.artos.packages.${pkgs.stdenv.hostPlatform.system}.artos
    inputs.usfm-importer.packages.${pkgs.stdenv.hostPlatform.system}.usfm-importer
  ];
}

{
  pkgs,
  inputs,
  ...
}:

{
  environment.defaultPackages = [
    inputs.artos.packages.${pkgs.stdenv.hostPlatform.system}.artos
  ];
}

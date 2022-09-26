{ pkgs, inputs, ... }:

let
  pkgWithCategory = category: package: { inherit package category; };
  devos = pkgWithCategory "devos";
in
{
  commands = with pkgs; [
    (devos agenix)
    (devos inputs.deploy.packages.${pkgs.system}.deploy-rs)
  ];
}

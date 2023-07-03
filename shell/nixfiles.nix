{ pkgs, inputs, ... }:

let
  pkgWithCategory = category: package: { inherit package category; };
  nixfiles = pkgWithCategory "nixfiles";
in
{
  commands = with pkgs; [
    (nixfiles agenix)
    (nixfiles cachix)
    (nixfiles inputs.deploy.packages.${pkgs.system}.deploy-rs)
    (nixfiles inputs.nixos-generators.packages.${pkgs.system}.nixos-generate)
  ];
}

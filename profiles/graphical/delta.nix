{
  pkgs,
  inputs,
  ...
}:

# Zed's Delta is a prebuilt proprietary tarball; the official flake patchelfs it
# and disables its self-updater, so upgrades go through `nix flake update delta`.
# Note that `delta` on PATH is git-delta (see profiles/core/git.nix); the editor
# is reached through its desktop entry or as `delta-app`.
{
  environment.defaultPackages = [
    inputs.delta.packages.${pkgs.stdenv.hostPlatform.system}.delta
  ];
}

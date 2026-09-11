{ pkgs, ... }:

# Zed's Delta is distributed as a prebuilt tarball that self-updates on launch,
# so it lives in ~/.local/delta.app instead of the store. nix-ld provides the
# libraries its binaries expect to dlopen from the system.
{
  programs.nix-ld.libraries = with pkgs; [
    alsa-lib
    fontconfig
    freetype
    glib
    libGL
    libgit2
    libglvnd
    libxkbcommon
    sqlite
    vulkan-loader
    wayland
    xorg.libX11
    xorg.libXext
    xorg.libxcb
  ];
}

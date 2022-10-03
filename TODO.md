Fixes:
- [sway/swaylock] make sure wallpaper exists
- [sway] screencast cannot be stopped when started with keybinding

Improvments:
- [NetworkManager] manage connections with nix (create a module)
- [swaylock] improve style
- [pdbpp] package it
- unlock with the fingerprint reader without pressing enter first
- use impermanence
- add digga specific commands to build grunfeld sd card and bootstrap iso
  * nixos-generate --flake '.#grunfeld' --format sd-aarch64 --system aarch64-linux then unzstd -d filename -o nixos-sd-image-22.11.img then sudo dd if=nixos-sd-image-22.11.img of=/dev/sda bs=64K status=progress
  * nixos-generate --falke '.#bootstrap' --format iso
- [restic] install on laptop and ease the use for the grunfeld backup

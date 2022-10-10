# NixOS config for my personal computer and servers

## Bootstrap
To create a bootstrap ISO for a personal computer run:
```bash
$ nixos-generate --flake '.#bootstrap' --format iso
```

To create a ready to boot SD card for a RaspberryPi, do the following:
```bash
$ nixos-generate --flake '.#grunfeld' --format sd-aarch64 --system aarch64-linux
$ unzstd -d {the output path from the command above} -o nixos-sd-image.img
$ sudo dd if=nixos-sd-image.img of=/dev/sda bs=64K status=progress
```

# NixOS config for my personal computer and servers

![screenshot](./assets/screenshot.jpeg)

## Presentation

I have three [NixOS](https://nixos.org) machines:
- _carokann_: personal computer ([Framework](https://frame.work) laptop).
- _najdorf_: server where I deploy my self-hosted apps.
- _ginko_: RaspberryPi used as tailscale exit node.

The hosts communicate through [Tailscale](https://tailscale.com).

This repo is structured with [flake-parts](https://flake.parts/) and [haumea](https://github.com/nix-community/haumea) for automatic module/profile discovery, preserving all the convenience features from the original [digga](https://github.com/divnix/digga) setup.

### Directory Structure
```
nixfiles/
├── hosts/          → Host configurations
├── modules/        → Custom NixOS modules
├── hm-modules/     → Custom home-manager modules
├── profiles/       → Reusable configuration profiles
├── pkgs/           → Custom packages
├── lib/            → Custom lib functions
├── overlays/       → Additional overlays
└── shell/          → Development shell
```

### Software I use on my personal computer (carokann)

- Wayland compositor: [hyprland](https://hypr.land)
- Desktop shell: [Caelestia](https://github.com/caelestia-dots/shell)
- Editor: [kakoune](https://github.com/mawww/kakoune)
- Terminal: [wezterm](https://wezterm.org)
- Shell: [fish](https://fishshell.com)
- Browser: [zen](https://zen-browser.app/)

### Self-hosted apps on my server (najdorf)

Here's the list of the main services deployed through their NixOS modules:
- [Træfik](https://traefik.io/traefik)
- [Authelia](https://www.authelia.com)
- [LLDAP](https://github.com/lldap/lldap)
- [Nextcloud](https://nextcloud.com)
- [n8n](https://n8n.io/)
- [Immich](https://immich.app)
- [Home Assistant](https://www.home-assistant.io/)
- [goeland](https://github.com/slurdge/goeland)
- [Cockpit](https://cockpit-project.org/)
- [Dawarich](https://dawarich.app/)

I deploy some service as Docker containers through [Arion](https://github.com/hercules-ci/arion):
- [Calibre-web](https://github.com/janeczku/calibre-web)
- [Grist](https://www.getgrist.com/)
- [Obsidian Livesync](https://github.com/vrtmrz/obsidian-livesync)
- [Obsidian share-note](https://github.com/alangrainger/share-note)

Important data is backed up with [Restic](https://restic.net).


## Bootstrap
### PC
Create a bootstrap ISO for a personal computer run:
```bash
$ nixos-generate --flake '.#bootstrap' --format iso
```

Then install NixOS:
```bash
$ cd nixfiles
$ sudo disko --mode destroy,format,mount -f '.#carokann'
$ sudo mount /dev/mapper/cryptroot /mnt
$ sudo mkdir /mnt/boot
$ sudo mount /dev/nvme0n1p1 /mnt/boot
# Generate the hardware config for reference, change what you need before install
$ sudo nixos-generate-config --root /mnt --dir /home/sweenu
$ sudo nixos-install --flake '.#carokann' --root /mnt

# Enroll your fingerprint
$ sudo fprintd-enroll <username>
# Enroll TPM2 for dm-crypt
$ sudo systemd-cryptenroll --tpm2-device=auto /dev/nvme0n1p2
```

After logging in with tailscale and enabling SSH connections (`sudo tailscale set --ssh`), you can backup the important files:
- ~/.ssh
- ~/.local/share/fish/fish_history
- /etc/NetworkManager/system-connections (replace interface names: `sed -i 's/wlp166s0f0/wlp192s0/' *`)
- All documents from ~ that you want to keep

### Raspberry Pi
Create a ready-to-boot SD card for a RaspberryPi, do the following:
```bash
$ nixos-generate --flake '.#ginko' --format sd-aarch64 --system aarch64-linux
$ unzstd -d {the output path from the command above} -o nixos-sd-image.img
$ sudo dd if=nixos-sd-image.img of=/dev/sda bs=64K status=progress oflag=sync
```

### Server
Deploy the server config to a new machine:
```bash
# Add an auth key file to the tailscale module for unattended login.
# Then run:
$ nixos-anywhere --copy-host-keys --flake '.#najdorf' root@<ip-address>
# Copy the old server's host key
$ scp 'root@najdorf:/etc/ssh/ssh_host_*' root@najdorf-1:/etc/ssh/
# Stop all running services, then:
$ ssh root@najdorf 'ssh-keyscan -H najdorf-1 >> ~/.ssh/known_hosts'
$ ssh -f root@najdorf 'rsync -Aavz /opt/ root@najdorf-1:/opt > /home/sweenu/rsync.log 2>&1 &'
# Transfer Postgres database
$ ssh root@najdorf 'sudo -u postgres pg_dumpall > /root/pgdump_all.sql'
$ scp root@najdorf:/root/pgdump_all.sql root@najdorf-1:/root/
$ ssh root@najdorf-1 'sudo -u postgres psql -f /root/pgdump_all.sql'
# I made all Docker volumes bind mounts in /opt in order for this command to be enough for migrating everything important.
# Uncomment services in hosts/najdorf/default.nix and comment the tailscale-login service line.
# Remove najdorf from tailscale and change the tailscale name from najdorf-1 to najdorf.
# Change DNS records to point to the new server (on Cloudflare, change the IP scope of the API token to the new IP).
# Finally:
$ deploy '.#najdorf'
# All done!
```

sudo ssh-keygen -t ed25519 -N "" -f /etc/ssh/initrd_ssh_host_ed25519_key

## Acknowledgment:
* Thanks to the [digga](https://digga.divnix.com) people for making my life easier when I first started to use NixOS.
* Thanks to [soramanew](https://github.com/soramanew) for the amazing [caelestia shell](https://github.com/caelestia-dots/shell) and for the [hyprland config](https://github.com/caelestia-dots/caelestia/tree/e456e8abb90b94f2e6ae859f6e3b3ef2a5e27099/hypr) from which I took liberally.

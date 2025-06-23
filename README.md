# NixOS config for my personal computer and servers

![neofetch](./assets/neofetch_2022_10_15.png)

## Presentation

I have three [NixOS](https://nixos.org) machines:
- _carokann_: personal computer ([Framework](https://frame.work) laptop).
- _najdorf_: server where I deploy my self-hosted apps.
- _grunfeld_: main RaspberryPi that serves as a [snapcast](https://github.com/badaix/snapcast) server and a local backup.

The hosts communicate through [Tailscale](https://tailscale.com).

This repo is structured with the [digga](https://digga.divnix.com) flake library.

### Software I use on my personal computer (carokann)

- Wayland compositor: [sway](https://swaywm.org)
- Wayland bar: [Waybar](https://github.com/Alexays/Waybar) (style copied from [@KubquoA](https://github.com/KubqoA)'s [config](https://github.com/KubqoA/dotfiles))
- Notification manager: [mako](https://wayland.emersion.fr/mako)
- Editor: [kakoune](https://github.com/mawww/kakoune)
- Terminal: [wezterm](https://wezterm.org)
- Terminal multiplexer: [tmux](https://github.com/tmux/tmux)
- Shell: [fish](https://fishshell.com)
- Browser: [firefox](https://www.mozilla.org/en-US/firefox)

### Self-hosted apps on my server (najdorf)

I deploy most services as Docker containers through [Arion](https://github.com/hercules-ci/arion)

- [Træfik](https://traefik.io/traefik)
- [Authelia](https://www.authelia.com)
- [LLDAP](https://github.com/lldap/lldap)
- [Nextcloud](https://nextcloud.com)
- [Calibre-web](https://github.com/janeczku/calibre-web)
- [SimpleTorrent](https://github.com/boypt/simple-torrent)
- [goeland](https://github.com/slurdge/goeland)
- [Immich](https://immich.app)

Important data is backed up with [Restic](https://restic.net) to a local disk connected to my RaspberryPi.


## Bootstrap
To create a bootstrap ISO for a personal computer run:
```bash
$ nixos-generate --flake '.#bootstrap' --format iso
```

To create a ready-to-boot SD card for a RaspberryPi, do the following:
```bash
$ nixos-generate --flake '.#grunfeld' --format sd-aarch64 --system aarch64-linux
$ unzstd -d {the output path from the command above} -o nixos-sd-image.img
$ sudo dd if=nixos-sd-image.img of=/dev/sda bs=64K status=progress
```

To deploy the server config to a new machine:
```bash
# First, comment all services imported in hosts/najdorf/default.nix and uncomment the ts-oneshot-login service line.
# Then run:
$ nixos-anywhere --copy-host-keys --flake '.#najdorf' root@<ip-address>
# Copy the old server's host key
$ scp 'root@najdorf:/etc/ssh/ssh_host_*' root@najdorf-1:/etc/ssh/
# Stop all running services, then:
$ ssh root@najdorf 'ssh-keyscan -H najdorf-1 >> ~/.ssh/known_hosts'
$ ssh -f root@najdorf 'rsync -avz /opt root@najdorf-1:/opt > /home/sweenu/rsync.log 2>&1 &'
# I made all Docker volumes bind mounts in /opt in order for this command to be enough for migrating everything important.
# Uncomment services in hosts/najdorf/default.nix and comment the tailscale-login service line.
# Remove najdorf from tailscale and change the tailscale name from najdorf-1 to najdorf.
# Change DNS records to point to the new server (on Cloudflare, change the IP scope of the API token to the new IP).
# Finally:
$ deploy '.#najdorf'
# All done!
```

## Acknowledgment:
* Thanks to [@KubquoA](https://github.com/KubqoA) for making this [reddit post](https://www.reddit.com/r/unixporn/comments/lepmss/sway_simple_sway_on_nixos) from which I discovered NixOS and from which I stole the Waybar style.
* Thanks to the [digga](https://digga.divnix.com) people for making my life easier when I first started to use NixOS.

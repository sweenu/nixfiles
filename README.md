# NixOS config for my personal computer and servers

![neofetch](./assets/neofetch_2022_10_15.png)

## Presentation

I have three [NixOS](https://nixos.org) machines:
- _carokann_: my personal computer ([Framework](https://frame.work) laptop).
- _benoni_: my server ([Scaleway](https://scaleway.com) DEV1-M) where I deploy my self-hosted apps.
- _grunfeld_: my main RaspberryPi that serves as a [snapcast](https://github.com/badaix/snapcast) server and a local backup.

The hosts communicate through [Tailscale](https://tailscale.com).

This repo is structured with the [digga](https://digga.divnix.com) flake library.

### Software I use on my personal computer (carokann)

- Wayland compositor: [sway](https://swaywm.org)
- Wayland bar: [Waybar](https://github.com/Alexays/Waybar) (style copied from [@KubquoA](https://github.com/KubqoA)'s [config](https://github.com/KubqoA/dotfiles))
- Notification manager: [mako](https://wayland.emersion.fr/mako)
- Editor: [kakoune](https://github.com/mawww/kakoune)
- Terminal: [alacritty](https://github.com/alacritty/alacritty)
- Terminal multiplexer: [tmux](https://github.com/tmux/tmux)
- Shell: [fish](https://fishshell.com)
- Browser: [firefox](https://www.mozilla.org/en-US/firefox)

### Self-hosted apps on my server (benoni)

I deploy most services as Docker containers through [Arion](https://github.com/hercules-ci/arion)

- [Træfik](https://traefik.io/traefik)
- [Authelia](https://www.authelia.com)
- [Nextcloud](https://nextcloud.com)
- [Calibre-web](https://github.com/janeczku/calibre-web)
- [SimpleTorrent](https://github.com/boypt/simple-torrent)
- [SearXNG](https://docs.searxng.org)

Important data is backed up with [Restic](https://restic.net) to a local disk connect to my RaspberryPi.


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

## Acknowledgment:
* Thanks to [@KubquoA](https://github.com/KubqoA) for making this [reddit post](https://www.reddit.com/r/unixporn/comments/lepmss/sway_simple_sway_on_nixos) from which I discovered NixOS and from which I stole the Waybar style.
* Thanks to the [digga](https://digga.divnix.com) people for making my life easier when I first started to use NixOS.

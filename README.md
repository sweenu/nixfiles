# NixOS config for my personal computer and servers

![screenshot](./assets/screenshot.jpeg)

## Presentation

Here are my [NixOS](https://nixos.org) machines:
- _carokann_: personal computer ([Framework](https://frame.work) laptop).
- _najdorf_: server where I deploy my self-hosted apps.
- _ginko_: RaspberryPi used as tailscale exit node.

The hosts communicate through [Tailscale](https://tailscale.com).

This repo is structured with [flake-parts](https://flake.parts/) and [haumea](https://github.com/nix-community/haumea) for automatic module/profile discovery, preserving all the convenience features from the original [digga](https://github.com/divnix/digga) setup.

### Directory Structure
```
nixfiles/
├── hosts/          → Host configurations
├── profiles/       → Reusable configuration profiles
├── modules/        → Custom NixOS modules
├── hm-modules/     → Custom home-manager modules
├── pkgs/           → Custom packages
├── overlays/       → Additional overlays
├── lib.nix         → Custom lib functions
└── shell.nix       → Development shell
```

### Software I use on my personal computer (carokann)

- Wayland compositor: [hyprland](https://hypr.land)
- Desktop shell: [DankMaterialShell](https://danklinux.com/)
- Editor: [kakoune](https://github.com/mawww/kakoune) and [Zed](https://zed.dev/)
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
- [NocoDB](https://nocodb.com/)

Important data is backed up with [Restic](https://restic.net).


## Bootstrap
### PC
Create a bootstrap ISO and put it on your usb key:
```bash
nixos-generate --flake '.#bootstrap' --format iso
sudo dd if=your.iso of=/dev/sda bs=4M status=progress oflag=direct
```

Then, from that key, install NixOS:
```bash
cd nixfiles
sudo disko --mode destroy,format,mount -f '.#carokann'
sudo mount /dev/mapper/cryptroot /mnt
sudo mkdir /mnt/boot
sudo mount /dev/nvme0n1p1 /mnt/boot
# Generate the hardware config for reference, change what you need before install
sudo nixos-generate-config --root /mnt --dir /home/sweenu
sudo nixos-install --flake '.#carokann' --root /mnt

# Optional:
# Enroll your fingerprint
sudo fprintd-enroll sweenu
# Enroll TPM2 for dm-crypt (if enabled in config)
sudo systemd-cryptenroll --tpm2-device=auto /dev/nvme0n1p2
```

After logging in with tailscale and enabling SSH connections (`sudo tailscale set --ssh`), you can backup the important files:
- ~/.ssh
- ~/.local/share/fish/fish_history
- /etc/NetworkManager/system-connections (replace interface names: `sed -i 's/wlp166s0f0/wlp192s0/' *`)
- All documents from ~ that you want to keep

### Raspberry Pi
Create a ready-to-boot SD card for a RaspberryPi, do the following:
```bash
nixos-generate --flake '.#ginko' --format sd-aarch64 --system aarch64-linux
unzstd -d {the output path from the command above} -o nixos-sd-image.img
sudo dd if=nixos-sd-image.img of=/dev/sda bs=4M status=progress oflag=direct
```

### Server
Deploy the server config to a new machine:
```bash
# 0) Preperation
# Uncomment all services in hosts/najdorf/default.nix to have a minimal deployment at first.
# Generate a tailscale auth key for unattended login here: https://login.tailscale.com/admin/settings/keys, and add it through `services.tailscale.authKeyFile`. This way, your old and new server have direct access to each other.

# 1) Provision
# We use --copy-host-keys to temporarily allow agenix to decrypt the secrets.
nixos-anywhere --copy-host-keys --flake '.#najdorf' root@<ip-address>

# 2) Preserve SSH host identity
scp -p root@najdorf:/etc/ssh/ssh_host_* root@najdorf-1:/etc/ssh/

# 2b) (Optional) Generate an initrd SSH host key (only needed for remote LUKS unlock)
# See https://nixos.org/manual/nixos/unstable/options#opt-boot.initrd.network.ssh.hostKeys
ssh root@najdorf-1 'sudo ssh-keygen -t ed25519 -N "" -f /etc/ssh/initrd_ssh_host_ed25519_key'

# 3) Pre-populate known_hosts
ssh root@najdorf 'ssh-keyscan -H najdorf-1 >> ~/.ssh/known_hosts'

# 4) Freeze writes (stop apps that write into /opt + Postgres)
ssh root@najdorf 'systemctl stop docker || true; systemctl stop postgresql || true'  # adapt to your services

# 5) Copy /opt to new server
# Start a detached tmux session that runs the rsync
ssh root@najdorf 'tmux new-session -d -s migration "rsync -aAXH --numeric-ids --partial --info=progress2 --log-file=/root/rsync-opt.log /opt/ root@najdorf-1:/opt/"'
# Later: check progress by reattaching
ssh root@najdorf 'tmux attach-session -t migration'
# (Ctrl+B then D to detach again without stopping it)

# 6) Postgres migration
ssh root@najdorf 'sudo -u postgres pg_dumpall --clean --if-exists --no-role-passwords' \
  | ssh root@najdorf-1 'sudo -u postgres psql -X -v ON_ERROR_STOP=1 -d postgres'

# 7) Deploy all services
# Remove najdorf from tailscale and change the tailscale name from najdorf-1 to najdorf.
# Change DNS records to point to the new server (on Cloudflare, change the IP scope of the API token to the new IP).
# Uncomment the services in hosts/najdorf/default.nix
deploy '.#najdorf'
```

## Acknowledgment:
* Thanks to the [digga](https://digga.divnix.com) people for making my life easier when I first started to use NixOS and from which the current structure of the repo is still heavily inspired.

# Android phone running nix-on-droid (https://github.com/nix-community/nix-on-droid).
# Rebuild from the phone with: nix-on-droid switch --flake ~/nixfiles#phone
{
  config,
  lib,
  pkgs,
  profiles,
  ...
}:

let
  hmConfig = config.home-manager.users.${config.vars.username};
  palette = hmConfig.colorScheme.palette;
  flake = "${config.vars.home}/nixfiles#phone";
in
{
  imports = [
    ./hm-users-shim.nix
    ./nix-profile-fix.nix
    ./ytdl.nix
    ../../modules/vars.nix
    profiles.vars
  ]
  ++ (with profiles.core; [
    fish
    git
    home
    kak
    theme
  ]);

  # nix-on-droid has its own state versions, independent from NixOS'.
  system.stateVersion = "24.05";

  user = {
    userName = config.vars.username;
    shell = "${pkgs.fish}/bin/fish";
  };

  kak.lspLanguages = [ "nix" ];

  vars = {
    home = lib.mkForce config.user.home;
    terminal = lib.mkForce "xterm-256color";
    defaultBrowser = lib.mkForce "termux-open-url";
  };

  time.timeZone = config.vars.timezone;

  android-integration = {
    termux-open.enable = true;
    termux-open-url.enable = true;
    termux-reload-settings.enable = true;
    termux-setup-storage.enable = true;
    termux-wake-lock.enable = true;
    termux-wake-unlock.enable = true;
  };

  terminal = {
    font = "${config.vars.defaultMonoFont.package}/share/fonts/truetype/NerdFonts/DejaVuSansM/DejaVuSansMNerdFontMono-Regular.ttf";
    colors = lib.mapAttrs (_: color: "#${color}") {
      background = palette.base00;
      foreground = palette.base05;
      cursor = palette.base05;
      color0 = palette.base00;
      color1 = palette.base08;
      color2 = palette.base0B;
      color3 = palette.base0A;
      color4 = palette.base0D;
      color5 = palette.base0E;
      color6 = palette.base0C;
      color7 = palette.base05;
      color8 = palette.base03;
      color9 = palette.base08;
      color10 = palette.base0B;
      color11 = palette.base0A;
      color12 = palette.base0D;
      color13 = palette.base0E;
      color14 = palette.base0C;
      color15 = palette.base07;
    };
  };

  # The NixOS-only profiles/core/base.nix can't be imported, so this is its
  # package list minus what's useless on Android: hardware and root tools,
  # process and disk usage tools (sandboxed to the app) and dev tooling.
  # Unlike NixOS, everything here and in home.packages lands in one buildEnv
  # that fails on colliding files: drop duplicates or lower their priority.
  environment.packages = with pkgs; [
    bind
    curl
    diffutils
    fd
    file
    findutils
    gawk
    git
    gnugrep
    gnused
    gnutar
    gzip
    highlight
    (lib.lowPrio inetutils) # whois has its own package
    jq
    less
    man
    moreutils
    mosh
    nix-tree
    nvd
    openssh
    procps
    ripgrep
    rsync
    skim
    gtrash
    unzip
    wget2
    whois
    which
    xz
    yq
    zip
  ];

  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      warn-dirty = false
    '';
    substituters = [
      "https://nix-community.cachix.org"
      "https://sweenu.cachix.org"
    ];
    trustedPublicKeys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "sweenu.cachix.org-1:DvQl16NWBp41k5IlxTODTOrIThyGRj8/ekrXxEheBQ0="
    ];
  };

  environment.etcBackupExtension = ".bak";

  home-manager.users.${config.vars.username}.programs = {
    fish.shellAbbrs = {
      nrb = lib.mkForce "nix-on-droid";
      nrbs = lib.mkForce "nix-on-droid switch --flake ${flake}";
      nb = lib.mkForce "nix-on-droid build --flake ${flake}";
    };
    # Android only lets them see the app's own processes.
    bottom.enable = lib.mkForce false;
    btop.enable = lib.mkForce false;
    # Dev tooling, and nix-index's database is a big download for a phone.
    direnv.enable = lib.mkForce false;
    gh-dash.enable = lib.mkForce false;
    nix-index.enable = lib.mkForce false;
  };
}

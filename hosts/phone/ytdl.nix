# Share a YouTube link to nix-on-droid to download it with ytdl.
{ config, pkgs, ... }:

let
  # The app runs ~/bin/termux-url-opener outside proot, where /nix/store
  # doesn't resolve (nix-community/nix-on-droid#439). So it has to be a real
  # file using Android's sh, re-entering nix-on-droid through its login script.
  urlOpener = pkgs.writeText "termux-url-opener" ''
    #!/system/bin/sh
    exec ${config.build.installationDir}/bin/login ${pkgs.ytdl}/bin/ytdl "$@"
  '';
in
{
  environment.packages = [ pkgs.ytdl ];

  build.activation.termuxUrlOpener = ''
    $DRY_RUN_CMD mkdir $VERBOSE_ARG -p "${config.user.home}/bin"
    $DRY_RUN_CMD install $VERBOSE_ARG -m 755 ${urlOpener} "${config.user.home}/bin/termux-url-opener"
  '';
}

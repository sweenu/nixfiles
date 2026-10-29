{
  config,
  lib,
  pkgs,
  ...
}:

let
  lockVault = pkgs.writeShellApplication {
    name = "rbw-lock";
    runtimeInputs = [ pkgs.rbw ];
    # `rbw lock` would start an agent just to lock it, so only talk to one
    # that is already up.
    text = ''
      [ -S "''${XDG_RUNTIME_DIR:-}/rbw/socket" ] || exit 0
      rbw lock
    '';
  };
in
{
  services.systemd-lock-handler.enable = true;

  home-manager.users."${config.vars.username}" = {
    programs.rbw = {
      enable = true;

      settings = {
        email = "brunoinec@gmail.com";
        lock_timeout = 900; # 15min
        pinentry = pkgs.pinentry-qt;
      };
    };

    systemd.user.services.rbw-lock = {
      Unit = {
        Description = "Lock the rbw vault";
        Before = [ "lock.target" ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = lib.getExe lockVault;
      };

      Install = {
        WantedBy = [ "lock.target" ];
      };
    };
  };
}

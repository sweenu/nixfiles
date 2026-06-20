{ config, pkgs, ... }:

let
  user = config.vars.username;
  workdir = "/home/${user}/repos";
in
{
  environment.systemPackages = [ pkgs.claude-code ];

  systemd.services.claude-remote-control = {
    description = "Claude Code Remote Control (server mode)";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    path = [
      pkgs.git
      pkgs.bash
      pkgs.coreutils
      pkgs.gnused
      pkgs.gnugrep
      pkgs.findutils
      pkgs.openssh
      pkgs.curl
      config.nix.package
    ];

    environment.HOME = "/home/${user}";

    serviceConfig = {
      User = user;
      WorkingDirectory = workdir;
      ExecStart = "${pkgs.claude-code}/bin/claude remote-control --spawn same-dir --name najdorf";
      Restart = "always";
      RestartSec = 10;
    };
  };
}

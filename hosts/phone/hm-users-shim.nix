# nix-on-droid is single-user: its home-manager configuration lives in
# `home-manager.config` instead of NixOS' `home-manager.users.<name>`. Aliasing
# the latter onto the former lets the shared profiles, which write to (and read
# from) `home-manager.users.${config.vars.username}`, be imported unchanged.
{ config, lib, ... }:

let
  # Option paths can't depend on `config`, hence the duplicated username.
  username = "sweenu";
in
{
  imports = [
    (lib.mkAliasOptionModule [ "home-manager" "users" username ] [ "home-manager" "config" ])
  ];

  assertions = [
    {
      assertion = config.vars.username == username;
      message = "hosts/phone/hm-users-shim.nix: username must match vars.username (${config.vars.username}).";
    }
  ];
}

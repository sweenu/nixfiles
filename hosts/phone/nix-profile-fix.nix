# nix-on-droid's installPackages parses `nix profile list` with
# `cut -d ' ' -f 4`, which finds nothing in the multi-line format of current
# Nix, so it runs `nix profile remove` with no arguments and activation fails
# with "No packages specified". Remove the entry by name instead, which is a
# no-op when it isn't there. Install it with a higher priority than the
# default, so packages added by hand with `nix profile` that ship the same
# files don't fail activation either.
{ config, lib, ... }:

{
  # build.activation is types.attrs, merged with `//` in definition order, so
  # mkForce on one key does nothing, but sorting this definition last works.
  build.activation = lib.mkAfter {
    installPackages = ''
      if [[ -e "${config.user.home}/.nix-profile/manifest.json" ]]; then
        # Removing nix-on-droid-path also removes nix from PATH.
        nix_previous="$(command -v nix)"

        # Two non-atomic steps because of https://github.com/NixOS/nix/issues/6349
        $DRY_RUN_CMD $nix_previous profile remove $VERBOSE_ARG nix-on-droid-path
        $DRY_RUN_CMD $nix_previous profile install --priority 4 ${config.environment.path}

        unset nix_previous
      else
        $DRY_RUN_CMD nix-env --install ${config.environment.path}
      fi
    '';
  };
}

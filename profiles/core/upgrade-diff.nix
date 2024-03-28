# https://github.com/nix-community/srvos/blob/b3af8aed091d85e180a861695f2d57b3b2d24ba1/nixos/common/upgrade-diff.nix
{ config, pkgs, ... }:

{
  system.activationScripts.diff = {
    supportsDryActivation = true;
    text = ''
      if [[ -e /run/current-system ]]; then
        echo "--- diff to current-system"
        ${pkgs.nvd}/bin/nvd --color=always --nix-bin-dir=${config.nix.package}/bin diff /run/current-system "$systemConfig"
        echo "---"
      fi
    '';
  };
}

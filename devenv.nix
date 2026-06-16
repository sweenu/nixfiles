{
  pkgs,
  inputs,
  ...
}:

let
  flakeInputs = inputs.nixfiles.inputs;
in
{
  packages =
    with pkgs;
    [
      cachix
      git
      nix-output-monitor
      nixfmt
      nvd
      treefmt
    ]
    ++ [
      flakeInputs.agenix.packages.${pkgs.system}.default
      flakeInputs.deploy.packages.${pkgs.system}.default
      flakeInputs.nixos-anywhere.packages.${pkgs.system}.default
      flakeInputs.disko.packages.${pkgs.system}.default
    ];

  scripts.restic.exec = ''
    export RESTIC_PASSWORD="$(${pkgs.rage}/bin/rage -d -i $HOME/.ssh/id_ed25519 $DEVENV_ROOT/secrets/restic/password.age)"
    set -a
    source <(${pkgs.rage}/bin/rage -d -i $HOME/.ssh/id_ed25519 $DEVENV_ROOT/secrets/restic/env.age)
    set +a
    exec ${pkgs.restic}/bin/restic "$@"
  '';

  enterShell = ''
    echo ""
    echo "🚀 Welcome to nixfiles devshell"
    echo ""
    echo "Available tools:"
    echo "  - agenix: Secret management"
    echo "  - deploy-rs: Deployment tool"
    echo "  - nixos-anywhere: Remote NixOS installation"
    echo "  - disko: Declarative disk partitioning"
    echo "  - restic: Wrapper for the najdorf backup repository"
    echo ""
  '';
}

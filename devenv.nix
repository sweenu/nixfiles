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
      nixfmt-rfc-style
      nvd
      treefmt
    ]
    ++ [
      flakeInputs.agenix.packages.${pkgs.system}.default
      flakeInputs.deploy.packages.${pkgs.system}.default
      flakeInputs.nixos-anywhere.packages.${pkgs.system}.default
      flakeInputs.disko.packages.${pkgs.system}.default
    ];

  enterShell = ''
    echo ""
    echo "🚀 Welcome to nixfiles devshell"
    echo ""
    echo "Available tools:"
    echo "  - agenix: Secret management"
    echo "  - deploy-rs: Deployment tool"
    echo "  - nixos-anywhere: Remote NixOS installation"
    echo "  - disko: Declarative disk partitioning"
    echo ""
  '';
}

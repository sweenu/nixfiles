{
  config,
  pkgs,
  inputs',
}:

pkgs.mkShell {
  packages =
    with pkgs;
    [
      cachix
      git
      nix-output-monitor
      nvd
    ]
    ++ [
      config.treefmt.build.wrapper
      inputs'.agenix.packages.default
      inputs'.deploy.packages.default
      inputs'.nixos-generators.packages.default
      inputs'.nixos-anywhere.packages.default
      inputs'.disko.packages.default
    ];

  shellHook = ''
    echo ""
    echo "🚀 Welcome to nixfiles devshell"
    echo ""
    echo "Available tools:"
    echo "  - agenix: Secret management"
    echo "  - deploy-rs: Deployment tool"
    echo "  - nixos-generate: Generate NixOS images"
    echo "  - nixos-anywhere: Remote NixOS installation"
    echo "  - disko: Declarative disk partitioning"
    echo ""
  '';
}

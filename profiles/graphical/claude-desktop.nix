{
  pkgs,
  inputs,
  ...
}:

{
  # FHS variant so MCP servers can run inside the app.
  environment.defaultPackages = [
    inputs.claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop-fhs
  ];
}

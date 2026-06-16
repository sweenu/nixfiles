{
  config,
  pkgs,
  inputs,
  ...
}:

{
  home-manager.users."${config.vars.username}".programs.zed-editor = {
    enable = true;
    package = inputs.zed-kakoune.packages.${pkgs.stdenv.hostPlatform.system}.default;
    extensions = [
      "html"
      "nix"
      "qml"
      "git-firefly"
      "toml"
      "dockerfile"
      "sql"
      "csv"
    ];
    userSettings = {
      kakoune_mode = true;
      buffer_font_size = 14;
      auto_signature_help = true;
      show_whitespaces = "trailing";
    };
    userTasks = [ ];
    userKeymaps = (import ./user_keymap.nix { mod = "ctrl"; });
    extraPackages = with pkgs; [
      # python
      ruff
      ty

      # yaml
      yaml-language-server

      # go
      gopls
      golangci-lint-langserver
      delve

      # rust
      rust-analyzer
      lldb

      # nix
      nil
      nixd

      # html, css, json
      vscode-langservers-extracted

      # yaml
      yaml-language-server

      # c
      clang-tools

      # markdown
      marksman

      # protobuf
      buf
      pb

      # qml
      qt6.qtdeclarative
      qt6.qtbase
      qt6.wrapQtAppsHook
    ];
  };
}

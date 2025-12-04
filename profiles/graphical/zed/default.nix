{ config, pkgs, ... }:

{
  home-manager.users."${config.vars.username}".programs.zed-editor = {
    enable = true;
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
      helix_mode = true;
      buffer_font_size = 14;
      auto_signature_help = true;
      show_whitespaces = "trailing";
    };
    userTasks = [ ];
    userKeymaps = (import ./kakoune_keymap.nix) ++ (import ./user_keymap.nix { mod = "ctrl"; });
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

      # bash
      nodePackages.bash-language-server

      # javascript
      nodePackages.typescript-language-server

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

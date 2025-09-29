{ config, pkgs, ... }:

{
  home-manager.users."${config.vars.username}".programs.zed-editor =
    let
      mod = "ctrl";
    in
    {
      enable = true;
      extensions = [
        "qml"
      ];
      userSettings = {
        helix_mode = true;
        buffer_font_size = 14;
        auto_signature_help = true;
        show_whitespaces = "trailing";
      };
      userTasks = [ ];
      userKeymaps = [
        {
          context = "Workspace";
          bindings = {
            "${mod}-shift-r" = "workspace::Reload";

            "${mod}-g n" = "pane::ActivateNextItem";
            "${mod}-g p" = "pane::ActivatePreviousItem";
            "${mod}-g x" = "pane::CloseActiveItem";
            "${mod}-g X" = "pane::CloseAllItems";

            "${mod}-1" = [
              "pane::ActivateItem"
              0
            ];
            "${mod}-2" = [
              "pane::ActivateItem"
              1
            ];
            "${mod}-3" = [
              "pane::ActivateItem"
              2
            ];
            "${mod}-4" = [
              "pane::ActivateItem"
              3
            ];
            "${mod}-5" = [
              "pane::ActivateItem"
              4
            ];
            "${mod}-6" = [
              "pane::ActivateItem"
              5
            ];
            "${mod}-7" = [
              "pane::ActivateItem"
              6
            ];
            "${mod}-8" = [
              "pane::ActivateItem"
              7
            ];
            "${mod}-9" = [
              "pane::ActivateItem"
              8
            ];
            "${mod}-0" = [
              "pane::ActivateItem"
              9
            ];
            "${mod}-'" = "pane::ActivateLastItem";

            "${mod}-h" = "workspace::ActivatePaneLeft";
            "${mod}-j" = "workspace::ActivatePaneDown";
            "${mod}-k" = "workspace::ActivatePaneUp";
            "${mod}-l" = "workspace::ActivatePaneRight";

            "${mod}-shift-j" = "workspace::SwapPaneDown";
            "${mod}-shift-k" = "workspace::SwapPaneUp";
            "${mod}-shift-h" = "workspace::SwapPaneLeft";
            "${mod}-shift-l" = "workspace::SwapPaneRight";

            # Pane splits
            "alt-g v" = "pane::SplitDown";

            # Pane management
            "alt-tab" = "workspace::ToggleZoom";
          };
        }
        {
          context = "Editor && vim_mode != insert";
          bindings = {
            "${mod}-h" = "workspace::ActivatePaneLeft";
            "${mod}-j" = "workspace::ActivatePaneDown";
            "${mod}-k" = "workspace::ActivatePaneUp";
            "${mod}-l" = "workspace::ActivatePaneRight";
          };
        }
      ];
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

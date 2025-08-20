{ config, pkgs, ... }:

{
  home-manager.users."${config.vars.username}".programs.zed-editor = {
    enable = true;
    extensions = [ ];
    extraPackages = with pkgs;[
      nil
    ];
    userSettings = {
      helix_mode = true;
      buffer_font_size = 14;
      auto_signature_help = true;
      show_whitespace = "trailing";
    };
    userTasks = [ ];
    userKeymaps = [
      {
        context = "Workspace";
        bindings = {
          # Window navigation
          "alt-n" = "workspace::ActivateNextItem";
          "alt-p" = "workspace::ActivatePrevItem";
          "alt-enter" = "workspace::NewFile";
          "alt-shift-x" = "pane::CloseActiveItem";

          # Direct tab selection
          "alt-1" = [ "workspace::ActivateItem" 0 ];
          "alt-2" = [ "workspace::ActivateItem" 1 ];
          "alt-3" = [ "workspace::ActivateItem" 2 ];
          "alt-4" = [ "workspace::ActivateItem" 3 ];
          "alt-5" = [ "workspace::ActivateItem" 4 ];
          "alt-6" = [ "workspace::ActivateItem" 5 ];
          "alt-7" = [ "workspace::ActivateItem" 6 ];
          "alt-8" = [ "workspace::ActivateItem" 7 ];
          "alt-9" = [ "workspace::ActivateItem" 8 ];
          "alt-0" = [ "workspace::ActivateItem" 9 ];
          "alt-'" = "pane::ActivateLastItem";

          # Pane navigation
          "ctrl-h" = "workspace::ActivatePaneInDirection";
          "ctrl-j" = "workspace::ActivatePaneInDirection";
          "ctrl-k" = "workspace::ActivatePaneInDirection";
          "ctrl-l" = "workspace::ActivatePaneInDirection";

          # Pane splits
          "alt-v" = "pane::SplitDown";
          "alt-h" = "pane::SplitRight";

          # Pane management
          "alt-x" = "pane::CloseActiveItem";
          "alt-tab" = "workspace::ToggleZoom";

          # Session/window picker
          "alt-s" = "tab_switcher::Toggle";

          # Pane resizing
          "alt-down" = "workspace::SwapPaneInDirection";
          "alt-up" = "workspace::SwapPaneInDirection";
          "alt-left" = "workspace::SwapPaneInDirection";
          "alt-right" = "workspace::SwapPaneInDirection";
        };
      }
      {
        context = "Editor";
        bindings = {
          # Ensure pane navigation works in editor context too
          "ctrl-h" = "workspace::ActivatePaneInDirection";
          "ctrl-j" = "workspace::ActivatePaneInDirection";
          "ctrl-k" = "workspace::ActivatePaneInDirection";
          "ctrl-l" = "workspace::ActivatePaneInDirection";
        };
      }
    ];
  };
}

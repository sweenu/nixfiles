{ mod }:
[
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
]

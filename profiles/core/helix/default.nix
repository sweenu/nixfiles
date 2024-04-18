{ config, ... }:

{
  home-manager.users."${config.vars.username}".programs.helix = rec {
    enable = true;

    settings = {
      theme = "material_oceanic_transparent";
      editor = {
        cursor-shape.insert = "bar";
        soft-wrap.enable = true;
        statusline = {
          mode = {
            normal = "normal";
            insert = "insert";
            select = "select";
          };
        };
      };
      keys = {
        normal = {
          "*" = [ "move_prev_word_start" "move_next_word_end" "search_selection" "search_next" ];
          A-o = "add_newline_below";
          A-O = "add_newline_above"; # TODO: not working
          y = [ "yank" "yank_main_selection_to_clipboard" ];
          d = [ "yank_to_clipboard" "delete_selection" ];
        };
      };
    };

    themes.${settings.theme} = {
      inherits = "material_oceanic";
      "ui.background" = { };
      palette = let palette = config.home-manager.users."${config.vars.username}".colorScheme.palette; in {
        red = "#${palette.base08}";
        orange = "#${palette.base09}";
        yellow = "#${palette.base0A}";
        green = "#${palette.base0B}";
        cyan = "#${palette.base0C}";
        blue = "#${palette.base0D}";
        purple = "#${palette.base0E}";
        gray = "#${palette.base0F}";
        text = "#eeffff";
      };
    };
  };
}

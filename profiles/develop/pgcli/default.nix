{ config, ... }:

{
  home-manager.users."${config.vars.username}" = {
    programs.pgcli = {
      enable = true;
      settings = {
        main = {
          smart_completion = true;
          wider_completion_menu = false;
          multi_line = true;
          multi_line_mode = "psql";
          destructive_warning = true;
          expand = false;
          auto_expand = false;
          generate_aliases = true;
          log_file = "default";
          keyword_casing = "auto";
          casing_file = "default";
          generate_casing_file = false;
          case_column_headers = true;
          history_file = "default";
          log_level = "ERROR";
          asterisk_column_order = "table_order";
          qualify_columns = "if_more_than_one_table";
          search_path_filter = true;
          timing = true;
          table_format = "double";
          syntax_style = "paraiso-dark";
          vi = true;
          on_error = "STOP";
          row_limit = 0;
          less_chatty = true;
          # Quoted to preserve trailing space and the backslash.
          prompt = ''"\d> "'';
          min_num_menu_lines = 4;
          multiline_continuation_char = "";
          null_string = "<null>";
          enable_pager = true;
          keyring = false;
        };

        # Color values contain '#' which configobj treats as a comment marker
        # unless the value is quoted, so we embed literal quotes.
        colors = {
          "completion-menu.completion.current" = ''"bg:#ffffff #000000"'';
          "completion-menu.completion" = ''"bg:#008888 #ffffff"'';
          "completion-menu.meta.completion.current" = ''"bg:#44aaaa #000000"'';
          "completion-menu.meta.completion" = ''"bg:#448888 #ffffff"'';
          "completion-menu.multi-column-meta" = ''"bg:#aaffff #000000"'';
          "scrollbar.arrow" = ''"bg:#003333"'';
          scrollbar = ''"bg:#00aaaa"'';
          selected = ''"#ffffff bg:#6666aa"'';
          search = ''"#ffffff bg:#4444aa"'';
          "search.current" = ''"#ffffff bg:#44aa44"'';
          "bottom-toolbar" = ''"bg:#222222 #aaaaaa"'';
          "bottom-toolbar.off" = ''"bg:#222222 #888888"'';
          "bottom-toolbar.on" = ''"bg:#222222 #ffffff"'';
          "search-toolbar" = "noinherit bold";
          "search-toolbar.text" = "nobold";
          "system-toolbar" = "noinherit bold";
          "arg-toolbar" = "noinherit bold";
          "arg-toolbar.text" = "nobold";
          "bottom-toolbar.transaction.valid" = ''"bg:#222222 #00ff5f bold"'';
          "bottom-toolbar.transaction.failed" = ''"bg:#222222 #ff005f bold"'';
          "output.header" = ''"#00ff5f bold"'';
          "output.odd-row" = ''""'';
          "output.even-row" = ''""'';
        };

        # Queries are wrapped in configobj string quotes because they contain
        # commas and parentheses, which would otherwise be misinterpreted.
        "named queries" = {
          table_sizes = "'''SELECT nspname, relname, pg_size_pretty(pg_relation_size(c.oid)) as \"size\" FROM pg_class c LEFT JOIN pg_namespace n ON n.oid = c.relnamespace WHERE nspname NOT IN ('pg_catalog','information_schema') ORDER BY pg_relation_size(c.oid) DESC LIMIT 30'''";
          list_triggers = "\"SELECT tgname FROM pg_trigger WHERE tgrelid = '$1'::regclass\"";
          list_locks = "\"SELECT pid, state, usename, query, query_start FROM pg_stat_activity WHERE pid IN (SELECT pid FROM pg_locks l JOIN pg_class t ON l.relation = t.oid AND t.relkind = 'r' WHERE t.relname = '$1')\"";
        };

        data_formats = {
          decimal = "";
          float = "";
        };
      };
    };
  };
}

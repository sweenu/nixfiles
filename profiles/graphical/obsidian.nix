{ config, ... }:

{
  home-manager.users."${config.vars.username}".programs.obsidian = rec {
    enable = true;

    vaults.notes = {
      enable = true;
      target = "${config.vars.documentsFolder}/notes";
      settings = {
        corePlugins = [
          "backlink"
          "bases"
          "bookmarks"
          "canvas"
          "command-palette"
          "editor-status"
          "file-explorer"
          "file-recovery"
          "global-search"
          "graph"
          "note-composer"
          "outgoing-link"
          "outline"
          "page-preview"
          "slides"
          "switcher"
          "tag-pane"
          "templates"
          "word-count"
          "workspaces"
          {
            name = "templates";
            settings = {
              folder = "templates";
            };
          }
        ];

        hotkeys = defaultSettings.hotkeys // {
          "obsidian-shellcommands:shell-command-brj31pko08" = [
            {
              modifiers = [ "Alt" ];
              key = "E";
            }
          ];
        };
      };
    };

    defaultSettings = {
      app = {
        promptDelete = false;
        spellcheck = false;
        showInlineTitle = false;
        mobileToolbarCommands = [
          "editor:indent-list"
          "editor:unindent-list"
          "editor:insert-wikilink"
          "editor:insert-embed"
          "editor:insert-tag"
          "editor:attach-file"
          "editor:set-heading"
          "editor:toggle-bold"
          "editor:toggle-italics"
          "editor:toggle-strikethrough"
          "editor:toggle-highlight"
          "editor:toggle-code"
          "editor:toggle-blockquote"
          "editor:insert-link"
          "editor:toggle-bullet-list"
          "editor:toggle-numbered-list"
          "editor:toggle-checklist-status"
          "editor:undo"
          "editor:redo"
          "editor:configure-toolbar"
        ];
      };

      appearance = {
        accentColor = "#8215cb";
        theme = "obsidian";
        baseFontSize = 16;
        cssTheme = "Things";
        showViewHeader = true;
        showRibbon = false;
      };

      hotkeys = {
        "app:toggle-left-sidebar" = [
          {
            modifiers = [ "Alt" ];
            key = "S";
          }
        ];
        "insert-template" = [
          {
            modifiers = [ "Alt" ];
            key = "I";
          }
        ];
      };
    };

  };
}

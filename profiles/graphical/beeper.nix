{ config, ... }:

{
  home-manager.users."${config.vars.username}".programs.beeper = {
    enable = true;
    mergeWithExisting = true;
    overrideOnConflict = false;
    settings = {
      keybindings = {
        ARCHIVE_ALL_READ_THREADS = "disabled";
        TOGGLE_THREAD_READ = "disabled";
        TOGGLE_THREAD_MUTE = "disabled";
        SEND_FILE = {
          keys = [ "alt+o" ];
        };
        CREATE_NEW_CHAT = {
          keys = [ "alt+n" ];
        };
        TOGGLE_THREAD_ARCHIVE = {
          keys = [ "alt+a" ];
        };
        TOGGLE_THREAD_PIN = {
          keys = [ "alt+p" ];
        };
        HISTORY_NEXT_THREAD = {
          keys = [ "alt+j" ];
          disabled = true;
        };
        HISTORY_PREV_THREAD = {
          keys = [ "alt+k" ];
          disabled = true;
        };
        OPEN_PROFILE = "disabled";
        OPEN_REMIND_LATER_MENU = {
          keys = [ "alt+l" ];
        };
        SCROLL_TO_END_OF_CHAT = {
          keys = [ "alt+g" ];
        };
        SELECT_NEXT_THREAD = {
          keys = [ "alt+j" ];
        };
        SELECT_NEXT_UNREAD_THREAD = "disabled";
        SELECT_PREV_THREAD = {
          keys = [ "alt+k" ];
        };
        SWITCH_FIRST_9_THREADS = {
          keys = [ "alt" ];
        };
        TOGGLE_THREAD_INFO = {
          keys = [ "alt+i" ];
        };
        MINIMIZE_TO_TRAY = "disabled";
        QUIT_APP = "disabled";
        RELOAD_APP = {
          keys = [ "alt+shift+r" ];
        };
        REPORT_A_PROBLEM = "disabled";
        SEARCH = {
          keys = [ "alt+/" ];
        };
        SELECT_NEXT_ACCOUNT = "disabled";
        SELECT_PREV_ACCOUNT = "disabled";
        SEND_FEEDBACK = "disabled";
        TOGGLE_PREFS_PANE = "disabled";
        SWITCH_FIRST_9_ACCOUNTS = "disabled";
        TOGGLE_SIDEBAR = {
          keys = [ "alt+s" ];
        };
        TOGGLE_FILTER_BAR = "disabled";
        TOGGLE_HOTKEYS_MODAL = "disabled";
        DOWNLOAD_ATTACHMENTS = {
          keys = [ "alt+d" ];
        };
        EDIT_MESSAGE = {
          keys = [ "alt+e" ];
        };
        QUOTE_AND_REPLY = {
          keys = [ "alt+r" ];
        };
        FORWARD_MESSAGES = {
          keys = [ "alt+f" ];
        };
        SHOW_AUDIO_BAR = {
          keys = [ "alt+shift+a" ];
        };
        SCHEDULE_MESSAGE = {
          keys = [ "alt+shift+l" ];
        };
        SHOW_GIF_PICKER = {
          keys = [ "alt+shift+g" ];
        };
        SHOW_TRANSCRIBE_BAR = {
          keys = [ "alt+shift+t" ];
        };
      };
    };
  };
}

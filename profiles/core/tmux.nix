{ config, pkgs, ... }:

{
  home-manager.users."${config.vars.username}".programs.tmux = {
    enable = true;
    aggressiveResize = true;
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 100000;
    keyMode = "vi";
    prefix = "M-g";
    secureSocket = true;
    sensibleOnTop = false;
    plugins = with pkgs; [
      tmuxPlugins.yank
      tmuxPlugins.open
      tmuxPlugins.copycat
    ];
    extraConfig =
      let
        mod = "C";
      in
      ''
        ############
        # BINDINGS #
        ############
        bind -n ${mod}-h select-pane -L
        bind -n ${mod}-j select-pane -D
        bind -n ${mod}-k select-pane -U
        bind -n ${mod}-l select-pane -R
        bind p previous-window
        bind n next-window

        bind -T copy-mode-vi ${mod}-h select-pane -L
        bind -T copy-mode-vi ${mod}-j select-pane -D
        bind -T copy-mode-vi ${mod}-k select-pane -U
        bind -T copy-mode-vi ${mod}-l select-pane -R

        # reset scrollback buffer
        bind k clear-history

        # go to copy mode
        bind [ copy-mode

        # move pane to new window
        bind w break-pane

        # kill pane
        bind -n ${mod}-x kill-pane
        bind -n ${mod}-X kill-window

        # reload tmux conf
        bind -n M-r source-file ~/.config/tmux/tmux.conf \; display-message "Tmux conf reloaded"

        # resize panes
        bind -n -r M-Down resize-pane -D 2
        bind -n -r M-Up resize-pane -U 2
        bind -n -r M-Left resize-pane -L 2
        bind -n -r M-Right resize-pane -R 2

        # Vi copypaste mode
        bind -T copy-mode-vi v send -X begin-selection

        # Split horiziontal and vertical splits, instead of % and "
        # Also open them in the same directory
        bind v split-window -v -c '#{pane_current_path}'
        bind h split-window -h -c '#{pane_current_path}'

        # Open new window
        bind -n M-Enter new-window

        # Zoom on focused tab
        bind -n M-Tab resize-pane -Z

        # Detach client
        bind d detach-client

        # Client mode
        bind s choose-tree -s

        # Select windows
        bind -n M-1 select-window -t 1
        bind -n M-2 select-window -t 2
        bind -n M-3 select-window -t 3
        bind -n M-4 select-window -t 4
        bind -n M-5 select-window -t 5
        bind -n M-6 select-window -t 6
        bind -n M-7 select-window -t 7
        bind -n M-8 select-window -t 8
        bind -n M-9 select-window -t 9
        bind -n M-0 select-window -t 10
        bind -n "M-'" last-window

        ###########
        # SESSION #
        ###########
        # make inactive window's background dimmer
        set -g window-active-style bg=#161e22
        set -g window-style bg=terminal

        # renumber windows when a window is closed
        set -g renumber-windows on

        # disable running multiple commands pressing the prefix once
        set -g repeat-time 0

        # enable both visual message and bell on activity alerts
        set -g monitor-activity on
        set -g visual-activity on

        # tmux messages are displayed for 4 seconds
        set -g display-time 4000

        ##########
        # VISUAL #
        ##########
        # jellybeans theme created with tmuxline
        set -g status "on"
        set -g status-justify "left"
        set -g status-left-style "none"
        set -g status-right-style "none"
        set -g status-right-length "100"
        set -g status-left-length "100"
        setw -g window-status-activity-style "none"
        setw -g window-status-separator ""

        # colors
        set -g message-command-style "fg=colour253,bg=colour239"
        set -g pane-active-border-style "fg=colour103"
        set -g status-style "none,bg=colour236"
        set -g message-style "fg=colour253,bg=colour239"
        set -g pane-border-style "fg=colour239"
        set -g status-left "#[fg=colour236,bg=colour103] #S #[fg=colour103,bg=colour236,nobold,nounderscore,noitalics]"
        set -g status-right "#[fg=colour239,bg=colour236,nobold,nounderscore,noitalics]#[fg=colour248,bg=colour239] %Y-%m-%d  %H:%M #[fg=colour246,bg=colour239,nobold,nounderscore,noitalics]#[fg=colour236,bg=colour246] #h "
        setw -g window-status-style "none,fg=colour244,bg=colour236"
        setw -g window-status-format "#[fg=colour244,bg=colour236] #I #[fg=colour244,bg=colour236] #W "
        setw -g window-status-current-format "#[fg=colour236,bg=colour239,nobold,nounderscore,noitalics]#[fg=colour253,bg=colour239] #I #[fg=colour253,bg=colour239] #W #[fg=colour239,bg=colour236,nobold,nounderscore,noitalics]"
      '';
  };
}

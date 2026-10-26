[
  # Zen's Picture-in-Picture randomly requests maximize during playback and
  # would steal focus
  {
    match.class = "zen-twilight";
    suppress_event = "maximize";
  }

  # They use native transparency or we want them opaque
  {
    match.class = "dev\\.duxlabs\\..*|imv|swappy";
    opaque = true;
  }

  # Center all floating windows (not xwayland cause popups); the sized rules
  # below rely on this instead of centering themselves
  {
    match = {
      float = true;
      xwayland = false;
    };
    center = true;
  }

  # Float
  {
    match.class = "wev|imv|dev\\.duxlabs\\..*|org\\.kde\\.kdeconnect\\.sms";
    float = true;
  }
  {
    match = {
      class = "zoom";
      title = "menu window";
    };
    float = true;
  }

  # Float and resize
  {
    match.class = "com\\.saivert\\.pwvucontrol";
    float = true;
    size = [
      "monitor_w*0.6"
      "monitor_h*0.7"
    ];
  }
  {
    match.class = "com\\.nextcloud\\.desktopclient\\.nextcloud";
    float = true;
    size = [
      607
      607
    ];
  }
  {
    match.class = "wdisplays";
    float = true;
    size = [
      1021
      622
    ];
  }
  {
    match.class = "dev\\.duxlabs\\.files";
    float = true;
    size = [
      "monitor_w*0.7"
      "monitor_h*0.75"
    ];
  }

  # Dialogs
  {
    match.title = "(Select|Open)( a)? (File|Folder)(s)?";
    float = true;
  }
  {
    match.title = "File (Operation|Upload)( Progress)?";
    float = true;
  }
  {
    match.title = ".* Properties";
    float = true;
  }
  {
    match.title = "Export Image as PNG";
    float = true;
  }
  {
    match.title = "GIMP Crash Debug";
    float = true;
  }
  {
    match.title = "Save As";
    float = true;
  }
  {
    match = {
      class = "zen-twilight";
      title = "^Library$";
    };
    float = true;
  }

  # Picture in picture
  {
    match.title = "Picture(-| )in(-| )[Pp]icture";
    move = [
      "monitor_w-window_w-(monitor_w*0.02)"
      "monitor_h-window_h-(monitor_h*0.03)"
    ];
    size = [
      "monitor_w*0.25"
      "monitor_h*0.25"
    ];
    keep_aspect_ratio = true;
    float = true;
    pin = true;
  }

  # Fix some dragging issues with XWayland
  {
    match = {
      class = "^$";
      title = "^$";
      xwayland = true;
      float = true;
      fullscreen = false;
      pin = false;
    };
    no_focus = true;
  }

  # xwayland popups
  {
    match = {
      xwayland = true;
      title = "win[0-9]+";
    };
    no_dim = true;
    no_shadow = true;
    rounding = 10;
  }

  # Zen titles it "<brand> — Sharing Indicator", so don't match on Firefox
  {
    match.title = ".*— Sharing Indicator";
    suppress_event = "maximize fullscreen";
  }

  # on_created_empty alone only lands the window on special:music when it
  # appears while that workspace is still active, which qbz 2.1's Qt startup
  # is slow enough to miss. The class is com.blitzfc.qbz (confirmed against
  # hyprctl clients), not qbz as the old Slint build reported — the 2.1
  # Qt/QML rewrite takes its app id from StartupWMClass in the desktop file.
  {
    match.class = "com\\.blitzfc\\.qbz";
    workspace = "special:music";
  }
]

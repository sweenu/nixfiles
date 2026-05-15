[
  # They use native transparency or we want them opaque
  {
    match.class = "org\\.quickshell|imv|swappy";
    opaque = true;
  }

  # Center all floating windows (not xwayland cause popups)
  {
    match = {
      float = true;
      xwayland = false;
    };
    center = true;
  }

  # Float
  {
    match.class = "guifetch";
    float = true;
  }
  {
    match.class = "wev";
    float = true;
  }
  {
    match.class = "org\\.gnome\\.FileRoller";
    float = true;
  }
  {
    match.class = "file-roller";
    float = true;
  }
  {
    match.class = "feh";
    float = true;
  }
  {
    match.class = "imv";
    float = true;
  }
  {
    match.class = "system-config-printer";
    float = true;
  }
  {
    match.class = "org\\.quickshell";
    float = true;
  }
  {
    match = {
      class = "Zoom Workspace";
      title = "menu window";
    };
    float = true;
  }
  {
    match.class = "org\\.kde\\.kdeconnect\\.sms";
    float = true;
  }

  # Float, resize and center
  {
    match.class = "org\\.gnome\\.Settings";
    float = true;
    size = [
      "monitor_w*0.7"
      "monitor_h*0.8"
    ];
    center = true;
  }
  {
    match.class = "com\\.saivert\\.pwvucontrol";
    float = true;
    size = [
      "monitor_w*0.6"
      "monitor_h*0.7"
    ];
    center = true;
  }
  {
    match.class = "nwg-look";
    float = true;
    size = [
      "monitor_w*0.5"
      "monitor_h*0.6"
    ];
    center = true;
  }
  {
    match.class = "signal";
    float = true;
    size = [
      773
      471
    ];
    center = true;
  }
  {
    match.class = "com\\.nextcloud\\.desktopclient\\.nextcloud";
    float = true;
    size = [
      607
      607
    ];
    center = true;
  }
  {
    match.class = "wdisplays";
    float = true;
    size = [
      1021
      622
    ];
    center = true;
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
    match.title = "Library";
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

  # Kill Firefox sharing indicator
  {
    match.title = "Firefox.*Sharing Indicator";
    suppress_event = "maximize fullscreen";
  }

  # App specific
  {
    match.class = "Signal";
    workspace = "special:signal";
  }
]

[
  # They use native transparency or we want them opaque
  "opaque on, match:class org\\.quickshell|imv|swappy"

  # Center all floating windows (not xwayland cause popups)
  "center on, match:float true, match:xwayland false"

  # Float
  "float on, match:class guifetch"
  "float on, match:class wev"
  "float on, match:class org\\.gnome\\.FileRoller"
  "float on, match:class file-roller"
  "float on, match:class feh"
  "float on, match:class imv"
  "float on, match:class system-config-printer"
  "float on, match:class org\\.quickshell"
  "float on, match:class Zoom Workspace, match:title menu window"
  "float on, match:class org\\.kde\\.kdeconnect\\.sms"

  # Float, resize and center
  "float on, match:class org\\.gnome\\.Settings"
  "size (monitor_w*0.7) (monitor_h*0.8), match:class org\\.gnome\\.Settings"
  "center on, match:class org\\.gnome\\.Settings"

  "float on, match:class com\\.saivert\\.pwvucontrol"
  "size (monitor_w*0.6) (monitor_h*0.7), match:class com\\.saivert\\.pwvucontrol"
  "center on, match:class com\\.saivert\\.pwvucontrol"

  "float on, match:class nwg-look"
  "size (monitor_w*0.5) (monitor_h*0.6), match:class nwg-look"
  "center on, match:class nwg-look"

  "float on, match:class signal"
  "size 773 471, match:class signal"
  "center on, match:class signal"

  "float on, match:class com\\.nextcloud\\.desktopclient\\.nextcloud"
  "size 607 607, match:class com\\.nextcloud\\.desktopclient\\.nextcloud"
  "center on, match:class com\\.nextcloud\\.desktopclient\\.nextcloud"

  "float on, match:class wdisplays"
  "size 1021 622, match:class wdisplays"
  "center on, match:class wdisplays"

  "float on, match:class io\\.missioncenter\\.MissionCenter"
  "size (monitor_w*0.6) (monitor_h*0.6), match:class io\\.missioncenter\\.MissionCenter"
  "center on, match:class io\\.missioncenter\\.MissionCenter"

  # Dialogs
  "float on, match:title (Select|Open)( a)? (File|Folder)(s)?"
  "float on, match:title File (Operation|Upload)( Progress)?"
  "float on, match:title .* Properties"
  "float on, match:title Export Image as PNG"
  "float on, match:title GIMP Crash Debug"
  "float on, match:title Save As"
  "float on, match:title Library"

  # Picture in picture
  "match:title Picture(-| )in(-| )[Pp]icture, move (monitor_w-window_w-(monitor_w*0.02)) (monitor_h-window_h-(monitor_h*0.03))"
  "match:title Picture(-| )in(-| )[Pp]icture, size (monitor_w*0.25) (monitor_h*0.25)"
  "match:title Picture(-| )in(-| )[Pp]icture, keep_aspect_ratio on"
  "match:title Picture(-| )in(-| )[Pp]icture, float on"
  "match:title Picture(-| )in(-| )[Pp]icture, pin on"

  # xwayland popups
  "match:xwayland true, match:title win[0-9]+, no_dim on"
  "match:xwayland true, match:title win[0-9]+, no_shadow on"
  "match:xwayland true, match:title win[0-9]+, rounding 10"

  # Kill Firefox sharing indicator
  "match:title Firefox.*Sharing Indicator, suppress_event maximize fullscreen"

  # App specific
  "match:class Signal, workspace special:signal"
]

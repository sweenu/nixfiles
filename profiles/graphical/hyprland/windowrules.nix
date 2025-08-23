[
  "opaque, class:org\.quickshell|imv|swappy" # They use native transparency or we want them opaque
  "center 1, floating:1, xwayland:0  # Center all floating windows (not xwayland cause popups)"

  # Float
  "float, class:guifetch"
  "float, class:wev"
  "float, class:org\.gnome\.FileRoller"
  "float, class:file-roller"
  "float, class:feh"
  "float, class:imv"
  "float, class:system-config-printer"
  "float, class:org\.quickshell"
  "float, class:Zoom Workspace, title:menu window"
  "float, class:io.missioncenter.MissionCenter"
  "float, class:firefox, title:Extension .* Bitwarden"

  # Float, resize and center
  "float, class:org\.gnome\.Settings"
  "size 70% 80%, class:org\.gnome\.Settings"
  "center 1, class:org\.gnome\.Settings"
  "float, class:com\.saivert\.pwvucontrol"
  "size 60% 70%, class:com\.saivert\.pwvucontrol"
  "center 1, class:com\.saivert\.pwvucontrol"
  "float, class:nwg-look"
  "size 50% 60%, class:nwg-look"
  "center 1, class:nwg-look"
  "float, class:signal"
  "size 773 471, class:signal"
  "center 1, class:signal"
  "float, class:com\.nextcloud\.desktopclient\.nextcloud"
  "size 607 607, class:com\.nextcloud\.desktopclient\.nextcloud"
  "center 1, class:com\.nextcloud\.desktopclient\.nextcloud"
  "float, class:wdisplays"
  "size 1021 622, class:wdisplays"
  "center 1, class:wdisplays"

  # Dialogs
  "float, title:(Select|Open)( a)? (File|Folder)(s)?"
  "float, title:File (Operation|Upload)( Progress)?"
  "float, title:.* Properties"
  "float, title:Export Image as PNG"
  "float, title:GIMP Crash Debug"
  "float, title:Save As"
  "float, title:Library"

  # Picture in picture
  "move 100%-w-2% 100%-w-3%, title:Picture(-| )in(-| )[Pp]icture"
  "size <25% <25%, title:Picture(-| )in(-| )[Pp]icture"
  "keepaspectratio, title:Picture(-| )in(-| )[Pp]icture"
  "float, title:Picture(-| )in(-| )[Pp]icture"
  "pin, title:Picture(-| )in(-| )[Pp]icture"

  # xwayland popups
  "nodim, xwayland:1, title:win[0-9]+"
  "noshadow, xwayland:1, title:win[0-9]+"
  "rounding 10, xwayland:1, title:win[0-9]+"

  # Kill Firefox sharing indicator
  "suppressevent maximize fullscreen, title:Firefox.*Sharing Indicator"

  # App specific
  "workspace special:signal, class:Signal"
]

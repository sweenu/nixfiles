{
  lib,
  config,
  pkgs,
}:
let
  inherit (lib.generators) mkLuaInline;

  backlight = "${pkgs.backlight}/bin/backlight";
  dms = "dms ipc call";
  mod = "SUPER";

  # Dispatcher helpers
  exec = cmd: mkLuaInline ''hl.dsp.exec_cmd("${cmd}")'';
  killactive = mkLuaInline "hl.dsp.window.close()";
  exitHyprland = mkLuaInline "hl.dsp.exit()";
  movefocus = dir: mkLuaInline ''hl.dsp.focus({ direction = "${dir}" })'';
  movewindow = dir: mkLuaInline ''hl.dsp.window.move({ direction = "${dir}" })'';
  focusWorkspace = n: mkLuaInline "hl.dsp.focus({ workspace = ${toString n} })";
  moveToWorkspaceSilent = n: mkLuaInline "hl.dsp.window.move({ workspace = ${toString n} })";
  moveToWorkspace = n: mkLuaInline "hl.dsp.window.move({ workspace = ${toString n}, follow = true })";
  layoutmsg = msg: mkLuaInline ''hl.dsp.layout("${msg}")'';
  fullscreenMaximized = mkLuaInline ''hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" })'';
  fullscreenToggle = mkLuaInline ''hl.dsp.window.fullscreen({ action = "toggle" })'';
  toggleSpecial = name: mkLuaInline ''hl.dsp.workspace.toggle_special("${name}")'';
  submap = name: mkLuaInline ''hl.dsp.submap("${name}")'';
  resizeactive =
    x: y: mkLuaInline "hl.dsp.window.resize({ x = ${toString x}, y = ${toString y}, relative = true })";
  drag = mkLuaInline "hl.dsp.window.drag()";
  resizeMouse = mkLuaInline "hl.dsp.window.resize()";
  dpmsToggle = monitor: mkLuaInline ''hl.dsp.dpms({ action = "toggle", monitor = "${monitor}" })'';

  # Bind helpers
  bind = key: dsp: {
    _args = [
      key
      dsp
    ];
  };
  bindFlags = flags: key: dsp: {
    _args = [
      key
      dsp
      flags
    ];
  };
  bindLocked = bindFlags { locked = true; };
  bindLockedRepeat = bindFlags {
    locked = true;
    repeating = true;
  };
  bindRepeat = bindFlags { repeating = true; };
  bindMouse = bindFlags { mouse = true; };

  workspaces = [
    {
      key = "A";
      n = 1;
    }
    {
      key = "S";
      n = 2;
    }
    {
      key = "D";
      n = 3;
    }
    {
      key = "F";
      n = 4;
    }
    {
      key = "U";
      n = 5;
    }
    {
      key = "I";
      n = 6;
    }
    {
      key = "O";
      n = 7;
    }
    {
      key = "P";
      n = 8;
    }
  ];
in
[
  # Window management
  (bind "${mod} + X" killactive)
  (bind "${mod} + SHIFT + R" (exec "hyprctl reload"))
  (bind "${mod} + SHIFT + Q" exitHyprland)

  # Focus movement
  (bind "${mod} + H" (movefocus "left"))
  (bind "${mod} + J" (movefocus "down"))
  (bind "${mod} + K" (movefocus "up"))
  (bind "${mod} + L" (movefocus "right"))

  # Move windows
  (bind "${mod} + SHIFT + H" (movewindow "left"))
  (bind "${mod} + SHIFT + J" (movewindow "down"))
  (bind "${mod} + SHIFT + K" (movewindow "up"))
  (bind "${mod} + SHIFT + L" (movewindow "right"))
]
++ map (w: bind "${mod} + ${w.key}" (focusWorkspace w.n)) workspaces
++ map (w: bind "${mod} + SHIFT + ${w.key}" (moveToWorkspaceSilent w.n)) workspaces
++ map (w: bind "${mod} + CTRL + SHIFT + ${w.key}" (moveToWorkspace w.n)) workspaces
++ [
  # Layout controls
  (bind "${mod} + V" (layoutmsg "togglesplit"))
  (bind "${mod} + SHIFT + V" (layoutmsg "preselect d"))
  (bind "${mod} + TAB" fullscreenMaximized)
  (bind "F11" fullscreenToggle)

  # Apps
  (bind "${mod} + Space" (exec "${dms} spotlight toggle"))
  (bind "${mod} + Return" (exec "app2unit -- ${config.vars.terminalBin}"))
  (bind "${mod} + B" (exec "app2unit -- ${config.vars.defaultBrowser}"))
  (bind "${mod} + N" (exec "app2unit -- obsidian"))
  (bind "${mod} + Z" (exec "app2unit -- zeditor"))
  (bind "${mod} + SHIFT + Escape" (exec "app2unit -- ${dms} processlist open"))

  # Notifications
  (bind "${mod} + Comma" (exec "${dms} notifications clearAll"))
  (bind "${mod} + Period" (exec "${dms} notifications toggle"))

  # Soundcards
  (bind "${mod} + bracketleft" (exec "${dms} audio cycleoutput"))
  (bind "${mod} + bracketright" (exec "${dms} audio cycleoutput"))

  # Screen capture
  (bind "Print" (exec "dms screenshot full"))
  (bind "${mod} + Print" (exec "dms screenshot"))

  # Turn off laptop screen
  (bind "F9" (dpmsToggle "eDP-1"))

  # Inhibit suspend
  (bind "F12" (exec "${dms} inhibit toggle"))
  (bind "XF86AudioMedia" (exec "${dms} inhibit toggle"))

  # Special workspace
  (bind "${mod} + minus" (toggleSpecial "communication"))
  (bind "${mod} + M" (toggleSpecial "music"))
  (bind "${mod} + C" (toggleSpecial "calendar"))
  (bind "${mod} + CTRL + Space" (toggleSpecial "claude"))

  # Submaps
  (bind "${mod} + W" (submap "window"))

  # DMS
  (bind "${mod} + question" (exec "${dms} keybinds toggle hyprland"))
  (bind "${mod} + Escape" (exec "${dms} powermenu toggle"))

  # Locked binds (work even when input inhibitor is active)
  (bindLocked "XF86AudioMute" (exec "${dms} audio mute"))
  (bindLocked "XF86AudioMicMute" (exec "${dms} audio micmute"))
  (bindLocked "XF86AudioPlay" (exec "${dms} mpris playPause"))
  (bindLocked "XF86AudioNext" (exec "${dms} mpris next"))
  (bindLocked "XF86AudioPrev" (exec "${dms} mpris previous"))
  (bindLocked "XF86AudioStop" (exec "${dms} mpris stop"))

  # Volume (locked + repeating)
  (bindLockedRepeat "XF86AudioRaiseVolume" (exec "${dms} audio increment 5"))
  (bindLockedRepeat "XF86AudioLowerVolume" (exec "${dms} audio decrement 5"))

  # Backlight
  (bindLockedRepeat "XF86MonBrightnessUp" (exec "${backlight} inc"))
  (bindLockedRepeat "XF86MonBrightnessDown" (exec "${backlight} dec"))
  (bindLockedRepeat "SHIFT + XF86MonBrightnessUp" (exec "${dms} brightness increment 5 'ddc:i2c-15'"))
  (bindLockedRepeat "SHIFT + XF86MonBrightnessDown" (
    exec "${dms} brightness decrement 5 'ddc:i2c-15'"
  ))

  # Resizing windows (repeating)
  (bindRepeat "${mod} + left" (resizeactive (-10) 0))
  (bindRepeat "${mod} + right" (resizeactive 10 0))
  (bindRepeat "${mod} + up" (resizeactive 0 (-10)))
  (bindRepeat "${mod} + down" (resizeactive 0 10))

  # Mouse binds
  (bindMouse "${mod} + mouse:272" drag)
  (bindMouse "${mod} + mouse:273" resizeMouse)
]

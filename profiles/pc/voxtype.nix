{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Voxtype downloads whisper models to ~/.local/share on first run; pin one in
  # the store instead so the daemon never needs the network.
  model = pkgs.fetchurl {
    url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin";
    hash = "sha256-oDd5yG3zMjB19eeWyyzlAp8A7Ihp7uP9+4l6/jbG0AI=";
  };

  settings = {
    # $XDG_RUNTIME_DIR/voxtype/state, read by `voxtype status` for the DankBar widget.
    state_file = "auto";

    # Hyprland owns the keybindings, see graphical/hyprland/keybindings.nix.
    hotkey.enabled = false;

    audio = {
      device = "default";
      sample_rate = 16000;
      # Safety net for a toggle-mode recording left running by accident.
      max_duration_secs = 300;
    };

    whisper = {
      model = "${model}";
      language = "en";
      translate = false;
      on_demand_loading = false;

      # Voxtype otherwise caps itself at num_cpus.min(4); one thread per
      # physical core roughly halves the encode. Going past 6 (i.e. onto the
      # SMT siblings) measured no faster and just saturates the machine.
      threads = 6;

      # Off by default upstream: without it whisper pads every clip to its full
      # 30s context, so a 4s dictation costs the same as a 30s one. Scaling the
      # context to the clip is another ~3x. Upstream warns it can trigger
      # repetition loops, but only on large-v3/turbo, not base.
      context_window_optimization = true;
    };

    output = {
      mode = "type";
      fallback_to_clipboard = true;

      # The DankBar widget already shows idle/recording/transcribing, and the
      # text lands at the cursor, so notifications would only be noise.
      notification = {
        on_recording_start = false;
        on_recording_stop = false;
        on_transcription = false;
      };
    };

    status.icon_theme = "emoji";
  };
in
{
  home-manager.users."${config.vars.username}" = {
    home.packages = [ pkgs.voxtype ];

    xdg.configFile."voxtype/config.toml".source =
      (pkgs.formats.toml { }).generate "voxtype-config.toml"
        settings;

    systemd.user.services.voxtype = {
      Unit = {
        Description = "Voxtype push-to-talk voice-to-text daemon";
        After = [
          "graphical-session.target"
          "pipewire.service"
        ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${lib.getExe pkgs.voxtype} daemon";
        Restart = "on-failure";
        RestartSec = "5s";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}

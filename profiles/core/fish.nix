{ config, pkgs, ... }:

{
  home-manager.users."${config.vars.username}" = {
    home.packages = with pkgs; [ eza ];
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        fish_vi_key_bindings
        set sponge_purge_only_on_exit true
      '';
      shellAbbrs = rec {
        # nix
        n = "nix";
        np = "nix profile";
        ni = "${np} install";
        nr = "${np} remove";
        ns = "nix search --no-update-lock-file nixpkgs";
        nf = "nix flake";
        nepl = "nix repl '<nixpkgs>'";
        nrb = ''nixos-rebuild --sudo --flake "$(pwd)#$(hostname)"'';
        nrbs = "nb $(hostname) && ${nrb} switch";
        ndiff = "${pkgs.nvd}/bin/nvd diff --sort semver /nix/var/nix/profiles/(ls -r /nix/var/nix/profiles/ | grep -E 'system-' | sed -n '2 p') /nix/var/nix/profiles/system";

        # sudo
        s = "sudo -E";
        si = "sudo -i";
        se = "sudoedit";

        # git
        g = "git";
        ga = "git add";
        "ga." = "git add .";
        gamend = "git commit --amend --no-edit";
        gb = "git branch";
        gc = "git commit";
        gco = "git checkout";
        gd = "git diff";
        gds = "git diff --staged";
        gp = "git push";
        gpf = "git push --force-with-lease";
        grc = "git rebase --continue";
        gri = "git rebase --interactive";
        gra = "git rebase --abort";
        grs = "git rebase --skip";
        gs = "git status --short";
        gS = "git status";
        gst = "git stash";
        gstl = "git stash list";
        gstp = "git stash pop";

        # systemd
        ctl = "sudo systemctl";
        utl = "systemctl --user";
        up = "sudo systemctl start";
        dn = "sudo systemctl stop";
        jtl = "journalctl";

        # apps
        py = "ptpython";
        kc = "kdeconnect-cli -n Mamène";
        hs = "nmcli connection up hs";
      };
      functions = {
        fish_greeting = "";
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        "....." = "cd ../../../..";
        ls = "eza $argv";
        la = "eza -laa $argv";
        tree = "eza -T $argv";
        wget = "wget2 $argv";
        bwu = "set -Ux BW_SESSION (bw unlock --raw)";
        genpass = "bw generate -ulns --length 16";
        pyclean = "find . | grep -E '(__pycache__|\.pyc|\.pyo$)' | xargs rm -rf";
        trash = "gtrash $argv";
        tp = "trash put $argv";
        rm = "echo 'Stop using rm, use trash put (or tp) instead'";
        k = "kak $argv";
        h = "hx $argv";
        myip = "dig +short myip.opendns.com @208.67.222.222 2>&1";
        mn = ''manix "" | grep '^# ' | sed 's/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //' | sk --preview="manix '{}'" | xargs manix'';
        nb = "${pkgs.nix-output-monitor}/bin/nom build .#nixosConfigurations.$argv.config.system.build.toplevel";
        nm-wifi = {
          body = "nmcli -t -f SSID device wifi list | sk | xargs -o -I_ nmcli --ask dev wifi connect '_'";
          description = "Fuzzy connect to a wifi";
        };
        nm-con = {
          body = "nmcli -t -f NAME con show | sk | xargs -o -I_ nmcli con up '_'";
          description = "Fuzzy activate a connection";
        };
        activate-combined-output = "${pkgs.pulseaudio}/bin/pactl load-module module-combine-sink";
        deactivate-combined-output = "${pkgs.pulseaudio}/bin/pactl unload-module module-combine-sink";
      };
      plugins = [
        {
          name = "anicode";
          src = pkgs.fetchFromGitHub {
            owner = "igalic";
            repo = "anicode";
            rev = "982709ba6619dd758e83c0e7126356fccabf2379";
            sha256 = "Vu1gioUMbCa/AVTMQMkC+dskcUqXyHP6Tay/gsVu+Pc=";
          };
        }
        {
          name = "done";
          src = pkgs.fetchFromGitHub {
            owner = "franciscolourenco";
            repo = "done";
            rev = "1.16.5";
            sha256 = "E0wveeDw1VzEH2kzn63q9hy1xkccfxQHBV2gVpu2IdQ=";
          };
        }
        {
          name = "sponge";
          src = pkgs.fetchFromGitHub {
            owner = "meaningful-ooo";
            repo = "sponge";
            rev = "1.1.0";
            sha256 = "MdcZUDRtNJdiyo2l9o5ma7nAX84xEJbGFhAVhK+Zm1w=";
          };
        }
      ];
    };

    programs = {
      starship = {
        enable = true;
      };
      nix-index = {
        enable = true;
      };
      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
    };

    home.sessionVariables = {
      DIRENV_LOG_FORMAT = "";
    };
  };
}

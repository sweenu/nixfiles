{ config, pkgs, ... }:
{
  home-manager.users."${config.vars.username}" = {
    programs.fish.functions = {
      nnn = "PDFTOTEXT=1 command nnn -a -Pp $argv";
    };
    programs.nnn = {
      enable = true;
      plugins = {
        src = (pkgs.fetchFromGitHub {
          owner = "jarun";
          repo = "nnn";
          rev = "6f08f7c35bc117a474580272dfd330de41852144";
          sha256 = "sha256-PMUMigiC7Tuhj5FrJwjsxgSBqHHRhTojjVsu7zGdLfQ=";
        }) + "/plugins";
        mappings = { p = "preview-tui"; };
      };
      extraPackages = with pkgs; [
        # preview-tui
        # required dependencies
        less
        exa
        file
        coreutils
        unzip
        gnutar
        man
        # optional dependencies
        atool
        bat
        viu
        imagemagick
        ffmpegthumbnailer
        ffmpeg
        libreoffice
        poppler_utils
        glow
        w3m
      ];
    };
  };
}

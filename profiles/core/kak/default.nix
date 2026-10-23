{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.kak;
in
{
  options.kak.lsp.enable = lib.mkEnableOption "kak-lsp and its language servers" // {
    default = true;
  };

  config.home-manager.users."${config.vars.username}" = {
    home.packages = with pkgs; [
      pkgs.nixfmt
      fedit
      perl # used by kakoune for some commands
    ];

    xdg.configFile."kak/colors/kanagawa.kak".source = ./colors/kanagawa.kak;

    programs.kakoune = {
      enable = true;
      extraConfig =
        builtins.readFile ./kakrc
        + lib.optionalString cfg.lsp.enable ("\n" + builtins.readFile ./kak-lsp.kak);
      plugins =
        with pkgs.kakounePlugins;
        [
          kak-fzf
          kak-auto-pairs
          kak-surround
          kak-sudo-write
          kak-find
        ]
        ++ lib.optional cfg.lsp.enable kakoune-lsp;
    };

    xdg.configFile."kak-lsp/kak-lsp.toml" = lib.mkIf cfg.lsp.enable {
      text = ''
        verbosity = 2

        [language.nix]
        filetypes = ["nix"]
        roots = ["flake.nix", "shell.nix", ".git", ".hg"]
        command = "${pkgs.nil}/bin/nil"

        [language.go]
        filetypes = ["go"]
        roots = ["Gopkg.toml", "go.mod", ".git", ".hg"]
        command = "${pkgs.gopls}/bin/gopls"
        settings_section = "gopls"

        [language.python]
        filetypes = ["python"]
        roots = ["pyproject.toml", "requirements.txt", "setup.py", ".git", ".hg"]
        command = "${pkgs.python3Packages.python-lsp-server}/bin/pylsp"
        settings_section = "_"
        [language.python.settings._]
        pylsp.configurationSources = ["flake8"]
        pylsp.plugins.flake8.enabled = true
        pylsp.plugins.mccabe.enabled = false
        pylsp.plugins.pycodestyle.enabled = false
        pylsp.plugins.pylint.enabled = false
        pylsp.plugins.yapf.enabled = false
      '';
    };
  };
}

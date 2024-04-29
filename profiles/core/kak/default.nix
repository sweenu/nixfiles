{ config, pkgs, ... }:
{
  home-manager.users."${config.vars.username}" = {
    home.packages = with pkgs; [
      nixpkgs-fmt
      fedit
    ];

    programs.kakoune = {
      enable = true;
      extraConfig = builtins.readFile ./kakrc;
      plugins = with pkgs.kakounePlugins; [
        kak-fzf
        kak-auto-pairs
        kakoune-lsp
        kak-surround
        kak-sudo-write
        kak-find
      ];
    };

    xdg.configFile."kak-lsp/kak-lsp.toml".text = ''
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
}

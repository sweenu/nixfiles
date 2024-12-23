{ config, pkgs, ... }:

{
  home-manager.users."${config.vars.username}".programs.helix = {
    languages = {
      language = [
        {
          name = "nix";
          formatter.command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
          auto-format = true;
        }
        {
          name = "python";
          # formatter = { command = "${pkgs.ruff}/bin/ruff"; args = ["format"]; };
          language-servers = [
            "pylsp"
            "ruff"
          ];
          auto-format = true;
        }
      ];

      language-server = {
        ruff = {
          command = "${pkgs.ruff}/bin/ruff";
          args = [
            "server"
            "--preview"
          ];
        };
        pylsp = {
          command = "${pkgs.python311Packages.python-lsp-server}/bin/pylsp";
          config = {
            pylsp = {
              plugins = {
                # TODO: find out why it doesn't work
                pylsp_mypy.enabled = true;
              };
            };
          };
        };
      };
    };

    extraPackages = with pkgs; [
      # python
      python311Packages.jedi
      python311Packages.rope
      python311Packages.pylsp-rope
      python311Packages.pylsp-mypy

      # go
      gopls
      golangci-lint-langserver
      delve

      # rust
      rust-analyzer
      lldb

      # nix
      nil

      # html, css, json
      vscode-langservers-extracted

      # yaml
      yaml-language-server

      # C
      clang-tools

      # bash
      nodePackages.bash-language-server

      # javascript
      nodePackages.typescript-language-server

      # markdown
      marksman

      # protobuf
      buf
      pb
    ];
  };
}

{
  description = "sweenu's hosts' setup";

  inputs = {
    nixos.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOs/nixos-hardware/master";

    digga.url = "github:divnix/digga";
    digga.inputs.nixpkgs.follows = "nixos";
    digga.inputs.latest.follows = "nixos";
    digga.inputs.nixlib.follows = "nixos";
    digga.inputs.home-manager.follows = "home";
    digga.inputs.deploy.follows = "deploy";

    home.url = "github:nix-community/home-manager";
    home.inputs.nixpkgs.follows = "nixos";

    agenix.url = "github:yaxitech/ragenix";
    agenix.inputs.nixpkgs.follows = "nixos";

    deploy.url = "github:serokell/deploy-rs";
    deploy.inputs.nixpkgs.follows = "nixos";

    nixos-generators.url = "github:nix-community/nixos-generators";

    arion.url = "github:hercules-ci/arion";
  };

  outputs = { self, nixos, nixos-hardware, digga, home, agenix, deploy, nixos-generators, arion } @ inputs:
    digga.lib.mkFlake {
      inherit self inputs;

      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      channelsConfig.allowUnfree = true;
      channels.nixos = {
        imports = [ (digga.lib.importOverlays ./overlays) ];
        overlays = [
          agenix.overlays.default
          ./pkgs/default.nix
        ];
      };

      nixos = {
        hostDefaults = {
          system = "x86_64-linux";
          channelName = "nixos";
          imports = [ (digga.lib.importExportableModules ./modules) ];
          modules = [
            agenix.nixosModules.age
            home.nixosModules.home-manager
            arion.nixosModules.arion
          ];
        };

        imports = [ (digga.lib.importHosts ./hosts) ];

        importables = rec {
          profiles = digga.lib.rakeLeaves ./profiles;
          suites = with builtins; let explodeAttrs = set: map (a: getAttr a set) (attrNames set); in
          with profiles; rec {
            base = (explodeAttrs core) ++ [ vars ];
            desktop = base ++ [ audio snapclient ] ++ (explodeAttrs graphical) ++ (explodeAttrs pc) ++ (explodeAttrs hardware) ++ (explodeAttrs develop);
            laptop = desktop ++ [ profiles.laptop ];
          };
        };

        hosts = {
          carokann.modules = [ nixos-hardware.nixosModules.framework-12th-gen-intel ];
          grunfeld.system = "aarch64-linux";
        };
      };

      devshell = ./shell;

      homeConfigurations = digga.lib.mkHomeConfigurations self.nixosConfigurations;

      deploy.nodes = digga.lib.mkDeployNodes self.nixosConfigurations {
        benoni = {
          profilesOrder = [ "system" "sweenu" ];
          profiles.system.sshUser = "root";
          profiles.sweenu = {
            user = "sweenu";
            sshUser = "root";
            path = deploy.lib.x86_64-linux.activate.home-manager self.homeConfigurations."sweenu@benoni";
          };
        };
        grunfeld = {
          profiles.system.sshUser = "root";
        };
      };
    };
}

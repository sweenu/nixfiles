{
  description = "sweenu's hosts' setup";

  inputs = {
    nixos.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOs/nixos-hardware/master";

    digga.url = "github:divnix/digga";
    digga.inputs.nixpkgs.follows = "nixos";
    digga.inputs.nixlib.follows = "nixos";
    digga.inputs.home-manager.follows = "home";
    digga.inputs.deploy.follows = "deploy";
    digga.inputs.flake-utils-plus.follows = "flake-utils-plus";

    home.url = "github:nix-community/home-manager";
    home.inputs.nixpkgs.follows = "nixos";

    # pin because of some bug
    agenix.url = "github:ryantm/agenix/2994d002dcff5353ca1ac48ec584c7f6589fe447";
    agenix.inputs.nixpkgs.follows = "nixos";

    deploy.url = "github:serokell/deploy-rs";
    deploy.inputs.nixpkgs.follows = "nixos";

    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixos";

    arion.url = "github:hercules-ci/arion";
    arion.inputs.nixpkgs.follows = "nixos";

    ig-story-fetcher.url = "github:sweenu/ig-story-fetcher";
    ig-story-fetcher.inputs.nixpkgs.follows = "nixos";

    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus";
  };

  outputs = { self, nixos, nixos-hardware, digga, home, agenix, deploy, nixos-generators, arion, ig-story-fetcher, flake-utils-plus } @ inputs:
    digga.lib.mkFlake {
      inherit self inputs;

      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      channelsConfig.allowUnfree = true;
      channelsConfig.permittedInsecurePackages = [ "electron-24.8.6" ];
      channels.nixos = {
        imports = [ (digga.lib.importOverlays ./overlays) ];
        overlays = [
          ./pkgs/default.nix
          agenix.overlays.default
          ig-story-fetcher.overlays.default
          deploy.overlay
          (self: super: { deploy = { inherit (nixos) deploy-rs; lib = super.deploy-rs.lib; }; })
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
            ig-story-fetcher.nixosModules.ig-story-fetcher
          ];
        };

        imports = [ (digga.lib.importHosts ./hosts) ];

        importables = rec {
          profiles = digga.lib.rakeLeaves ./profiles;
          suites = with builtins; let explodeAttrs = set: map (a: getAttr a set) (attrNames set); in
          with profiles; rec {
            base = (explodeAttrs core) ++ [ vars ];
            server = [ profiles.server vars core.cachix ];
            desktop = base ++ [ audio virt-manager ] ++ (explodeAttrs graphical) ++ (explodeAttrs pc) ++ (explodeAttrs hardware) ++ (explodeAttrs develop);
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
        najdorf = {
          profilesOrder = [ "system" "sweenu" ];
          profiles.system.sshUser = "root";
          profiles.sweenu = {
            user = "sweenu";
            sshUser = "root";
            path = deploy.lib.x86_64-linux.activate.home-manager self.homeConfigurations."sweenu@najdorf";
          };
        };
        grunfeld = {
          profiles.system.sshUser = "root";
        };
      };

      herculesCI = {
        ciSystems = [ "x86_64-linux" ];
      };
    };
}

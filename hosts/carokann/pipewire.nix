{
  services.pipewire.wireplumber.extraConfig = {
    "5-built-in-speakers-rename" = {
      "monitor.alsa.rules" = [
        {
          matches = [ { "node.name" = "alsa_output.pci-0000_c1_00.6.HiFi__Speaker__sink"; } ];
          actions = {
            update-props = {
              "node.nick" = "Built-in Speakers";
            };
          };
        }
      ];
    };
    # See https://github.com/NixOS/nixos-hardware/issues/1603
    "no-ucm" = {
      "monitor.alsa.properties" = {
        "alsa.use-ucm" = false;
      };
    };
  };
}

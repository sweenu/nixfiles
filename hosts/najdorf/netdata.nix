{ pkgs, ... }:

{
  services.netdata = {
    enable = true;
    package = pkgs.netdata.override {
      withCloudUi = true;
    };
    python = {
      recommendedPythonPackages = true;
    };
  };

  # TODO: https://github.com/tailscale/tailscale/issues/18381
  # services.tailscale.serve.services.netdata.https."443" = "http://localhost:19999";
}

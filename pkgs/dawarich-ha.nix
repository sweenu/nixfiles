{
  dawarich-api,
  fetchFromGitHub,
  buildHomeAssistantComponent,
}:

buildHomeAssistantComponent rec {
  owner = "AlbinLind";
  domain = "dawarich";
  version = "0.8.5";

  src = fetchFromGitHub {
    inherit owner;
    repo = "dawarich-home-assistant";
    tag = version;
    hash = "sha256-T7f4z501jO2XWC4YQx7MEJSZY5ZAYXQb1vtYGcEVJU0";
  };

  dependencies = [
    dawarich-api
  ];
}

{
  aiobbox,
  fetchFromGitHub,
  buildHomeAssistantComponent,
}:

buildHomeAssistantComponent rec {
  owner = "sweenu";
  domain = "bbox";
  version = "0.1.0";

  src = fetchFromGitHub {
    inherit owner;
    repo = "bbox-ha";
    rev = "9713882882357f9da58946e05aee29ba6a05b966";
    hash = "sha256-WC6FQoKeMYDf5qdWq6TuBg5udUstGa6ilbIgoJDTlDg=";
  };

  dependencies = [
    aiobbox
  ];
}

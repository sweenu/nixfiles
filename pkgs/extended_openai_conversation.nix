{
  openai,
  fetchFromGitHub,
  buildHomeAssistantComponent,
}:

buildHomeAssistantComponent rec {
  owner = "jekalmin";
  domain = "extended_openai_conversation";
  version = "2.0.0";

  src = fetchFromGitHub {
    inherit owner;
    repo = domain;
    tag = version;
    hash = "sha256-/SeclMp1JDzcWOFARpEiawcCg3KYIkiC/6qQrJpVWkk=";
  };

  patches = [
    (builtins.toFile "relax-openai-version.patch" ''
      --- a/custom_components/extended_openai_conversation/manifest.json
      +++ b/custom_components/extended_openai_conversation/manifest.json
      @@ -10,7 +10,7 @@
         "iot_class": "cloud_polling",
         "issue_tracker": "https://github.com/jekalmin/extended_openai_conversation/issues",
         "requirements": [
      -    "openai~=2.8.0"
      +    "openai>=2.8.0"
         ],
         "version": "2.0.0"
       }
    '')
  ];

  dependencies = [ openai ];
}

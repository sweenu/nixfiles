{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  openai,
}:

buildHomeAssistantComponent rec {
  owner = "fabio-garavini";
  domain = "openai_whisper_cloud";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "fabio-garavini";
    repo = "ha-openai-whisper-stt-api";
    tag = version;
    hash = "sha256-EICSh0jJgY4Bbo3mThCO85k35GJ5NpoRrIxuWv4lZcs=";
  };

  propagatedBuildInputs = [
    openai
  ];

  meta = with lib; {
    description = "Home Assistant custom integration for OpenAI Whisper speech-to-text API (OpenAI, GroqCloud)";
    homepage = "https://github.com/fabio-garavini/ha-openai-whisper-stt-api";
    license = licenses.agpl3Only;
    # maintainers = with maintainers; [ sweenu ];
  };
}

{ self, config, ... }:

{
  age.secrets.vrisingDiscordBotToken.file = "${self}/secrets/vrising_discord_bot/bot_token.age";
  age.secrets.portainerAccessKey.file = "${self}/secrets/vrising_discord_bot/portainer_access_key.age";

  services.vrising-discord-bot = {
    enable = true;
    settings = {
      portainer = {
        base_url = "https://portainer.${config.vars.domainName}";
        environment_id = 2;
        container_name = "vrising";
        access_key_file = config.age.secrets.portainerAccessKey.path;
      };
      discord = {
        bot_token_file = config.age.secrets.vrisingDiscordBotToken.path;
        guild_id = 168769682403229697;
      };
    };
  };
}

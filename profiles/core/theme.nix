{ config, nix-colors, ... }:

{
   home-manager.users."${config.vars.username}".colorScheme = nix-colors.colorSchemes.oceanicnext;
}

{ self, config, ... }:

{
  age.secrets.privateKeyFile.file = "${self}/secrets/proton_vpn_wireguard_private_key.age";

  networking.wg-quick.interfaces = {
    wg0 = {
      autostart = false;
      address = [ "10.2.0.2/32" ];
      dns = [ "10.2.0.1" ];
      privateKeyFile = config.age.secrets.privateKeyFile.path;
      peers = [
        {
          # NL-FREE#153
          publicKey = "1+Zfm0ZR01P0ZZi+dNC46mDJdiVOLoM+OQPGjL+Z7DE=";
          allowedIPs = [ "0.0.0.0/0" ];
          endpoint = "185.107.56.211:51820";
        }
      ];
    };
  };
}

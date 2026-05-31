{ ... }:
{
  sops = {
    age.keyFile = "/home/deepak/.config/sops/age/keys.txt";
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      anthropic_api_key = { };
      hello = { };
      newkey = { };
    };
  };
}

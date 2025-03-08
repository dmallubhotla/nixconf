# nixos config

Quite incomplete.


## Setup post install

* `obsidian` needs to be connected to vault repo
* auth `discord`
* auth `kubectl`
* `nextcloud-client` setup?
* git clone sd and nixconf directories 
* nixconf path will need to be set in env var most likely

## Update

* `nix flake update --recreate-lock-file`
* rebuild nixos (sd)


## Troubleshooting

If `sops-nix` is having trouble in WSL it could be because the user systemd set up doesn't get correctly started.
Using something like `systemctl restart user@1000` can be helpful (cf. [this link]{https://github.com/microsoft/WSL/issues/8842#issuecomment-2346387618})

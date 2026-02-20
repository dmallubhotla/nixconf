{
  inputs,
  customPackageOverlay,
}:
let
  lib = import ../lib {
    inherit inputs customPackageOverlay;
  };
in
{
  # WSL Hosts
  "nixosWalrus" = lib.mkWSLHost {
    hostname = "nixosWalrus";
    stateVersion = "24.11";
    withDocker = true;
    gitSigningKey = "8F904A3FC7021497";
    obsidian_dir = "/mnt/d/applications/obsidian/vault01";
  };

  "nixosEggYoke" = lib.mkWSLHost {
    hostname = "nixosEggYoke";
    stateVersion = "22.05";
    withDocker = true;
    gitSigningKey = "47831B15427F5A55";
  };

  # VM Hosts (example configuration)
  # Uncomment and customize when creating a VM
  #
  "nixosVM" = lib.mkVMHost {
    hostname = "nixosVM";
    stateVersion = "25.11";
    gitSigningKey = "YOUR_KEY_HERE";
    withDocker = true;
    withQemuAgent = true; # QEMU guest agent for host communication
    withCloudInit = false; # Enable for cloud deployments
    withGrowpart = true; # Auto-grow root partition
    withSerialConsole = true; # Serial console for debugging
    extraModules = [
      # Add hardware-configuration.nix or other VM-specific modules
      # ./nixosVM/hardware-configuration.nix
    ];
  };
}

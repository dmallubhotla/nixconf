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

  # Bare-metal Proxmox-NixOS hosts
  #
  # Required before first deploy:
  #   1. Run nixos-generate-config on shannon and replace
  #      hosts/shannon/hardware-configuration.nix with the output
  #   2. Update networking.bridges.vmbr0.interfaces in proxmox-configuration.nix
  #      with the correct NIC interface name (check `ip link` on installer)
  #   3. 192.168.1.41 for shannon
  "shannon" = lib.mkProxmoxHost {
    hostname = "shannon";
    stateVersion = "25.11";
    gitSigningKey = "047D7BB1D577BB54"; # update with Shannon's key if different
    hardwareConfig = ./shannon/hardware-configuration.nix;
    ipAddress = "192.168.1.41";
    bridges = [ "vmbr0" ];
    # Declarative VMs (optional — can also manage via Proxmox web UI)
    # vms = {
    #   talos-worker-01 = {
    #     vmid = 200;
    #     memory = 8192;
    #     cores = 4;
    #     sockets = 2;
    #     net = [{ model = "virtio"; bridge = "vmbr0"; }];
    #     scsi = [{ file = "local:50"; }];
    #   };
    # };
  };

  # VM Hosts (example configuration)
  # Uncomment and customize when creating a VM
  #
  "nixosVM" = lib.mkVMHost {
    hostname = "nixosVM";
    stateVersion = "25.11";
    gitSigningKey = "047D7BB1D577BB54";
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

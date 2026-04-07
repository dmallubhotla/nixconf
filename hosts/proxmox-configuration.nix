# Base configuration for bare-metal Proxmox-NixOS hosts.
# Runs Proxmox VE services on top of a NixOS kernel, avoiding the
# Proxmox installer kernel entirely. Useful when the PVE kernel causes
# hardware issues (MCEs, driver conflicts) that the NixOS kernel handles.
{
  pkgs,
  lib,
  customPackageOverlay,
  hostname,
  stateVersion,
  proxmox-nixos,
  ipAddress,
  bridges ? [ "vmbr0" ],
  vms ? { },
  withDocker ? false,
  ...
}:
let
  custom-fonts = import ../fonts { inherit pkgs; };
in
{
  imports = [
    # Proxmox VE NixOS module
    proxmox-nixos.nixosModules.proxmox-ve
  ];

  nixpkgs.overlays = [
    customPackageOverlay
    proxmox-nixos.overlays.x86_64-linux
  ];

  # Use the binary cache for proxmox-nixos to avoid expensive rebuilds
  nix.settings = {
    substituters = [
      "https://cache.nixos.org"
      "https://cache.saumon.network/proxmox-nixos"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "proxmox-nixos:D9RYSWpQQC/msZUWphOY2I5RLH5Dd6yQcaHIuug7dWM="
    ];
    trusted-users = [
      "root"
      "@wheel"
    ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    download-buffer-size = 524288000;
  };

  # Proxmox VE service configuration
  services.proxmox-ve = {
    enable = true;
    inherit ipAddress;
    inherit bridges;
    vms = lib.mkIf (vms != { }) vms;
  };

  # Boot: bare metal, not a VM
  boot.loader.grub = {
    enable = true;
    device = "/dev/sdb";
  };
  # boot.loader.efi.canTouchEfiVariables = true;

  # Dell PowerEdge hardware support
  boot.initrd.availableKernelModules = [
    # SCSI/SATA controllers (PERC H730, PERC H310, etc.)
    "megaraid_sas"
    "mpt3sas"
    "ahci"
    "xhci_pci"
    # Network
    "igb"
    "bnx2"
    "bnx2x"
    "be2net"
    "tg3"
    # Storage
    "sd_mod"
    "sr_mod"
  ];

  boot.kernelModules = [
    "kvm-intel" # or kvm-amd depending on CPU
    "megaraid_sas"
    "ipmi_devintf"
    "ipmi_si" # iDRAC/IPMI support
    "dm-thin-pool" # LVM thin provisioning for local-lvm
  ];

  # Enable IP forwarding for VM networking
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  networking.hostName = hostname;
  networking.useDHCP = lib.mkDefault false; # Proxmox manages networking

  # The bridge vmbr0 is configured here; Proxmox just references it by name.
  # Update the interface name (e.g., eno1, enp3s0) to match your hardware.
  # Run `ip link` on the installed system to find the right name.
  networking.bridges.vmbr0.interfaces = [ "eno4" ];
  networking.interfaces.vmbr0 = {
    useDHCP = lib.mkDefault true;
  };

  system.stateVersion = stateVersion;

  # User account (same pattern as commonVM)
  users.users.deepak = {
    isNormalUser = true;
    home = "/home/deepak";
    description = "Deepak Mallubhotla";
    extraGroups = [
      "wheel"
      "networkmanager"
      "users"
    ]
    ++ lib.optionals withDocker [ "docker" ];
    shell = pkgs.zsh;
    initialHashedPassword = "$y$j9T$cVagC4LC8iTozPVAW5uE10$vZiit3Ohx/fwA87p0C.9tzfz0D3ytec.hClUvOjnjF1";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC+yAxaiQ+98tfV2aAkwDVvWzEz5UCnkunrXzSkG8omp dmallubhotla@gmail.com"
    ];
  };

  # Terraform/OpenTofu service account for Proxmox API (PAM auth)
  users.users.terraform = {
    isNormalUser = true;
    home = "/home/terraform";
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC+yAxaiQ+98tfV2aAkwDVvWzEz5UCnkunrXzSkG8omp dmallubhotla@gmail.com"
    ];
  };

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    wget
    vim
    git
    htop
    iotop
    pciutils
    usbutils
    ipmitool # Dell iDRAC/IPMI management
    smartmontools # Disk health
    lm_sensors # Hardware temperature monitoring
    tailscale
    gnupg
    pinentry-curses
    # needed for lvm on proxmox
    gptfdisk # provides sgdisk
    lvm2 # provides pvcreate, vgcreate etc.
  ];

  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    custom-fonts.custom-fonts
  ];

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
    enableSSHSupport = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  services.tailscale = {
    enable = true;
    port = 62532;
    extraSetFlags = [ "--operator=deepak" ];
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22 # SSH
      8006 # Proxmox web UI
      3128 # Proxmox SPICE proxy
    ];
    allowedUDPPorts = [
      62532 # Tailscale
      5405 # Corosync (cluster, if joining Alan)
    ];
    # Allow all traffic on the bridge interface (VM networking)
    trustedInterfaces = [ "vmbr0" ];
  };

  time.timeZone = "America/Chicago";

  virtualisation.docker = lib.mkIf withDocker {
    enable = true;
  };

  nixpkgs.config.allowUnfree = false;

  documentation = {
    dev.enable = true;
    man.generateCaches = true;
    nixos.enable = true;
  };
}

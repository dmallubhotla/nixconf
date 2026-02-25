# Common configuration for VM guests (QEMU/KVM)
{
  pkgs,
  lib,
  customPackageOverlay,
  hostname,
  stateVersion,
  nixpkgs-unstable,
  withDocker ? false,
  withQemuAgent ? true,
  withCloudInit ? false,
  withGrowpart ? true,
  withSerialConsole ? true,
  inputs,
  ...
}:
let
  custom-fonts = import ../fonts { inherit pkgs; };
in
{
  # Boot configuration for VMs
  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
  };

  # Kernel modules for virtio
  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_scsi"
    "virtio_blk"
    "virtio_net"
    "virtio_balloon"
    "virtio_console"
    "9p"
    "9pnet_virtio"
  ];

  boot.kernelModules = [
    "virtio_balloon"
    "virtio_console"
    "virtio_rng"
  ];

  # Serial console for VM debugging
  boot.kernelParams = lib.optionals withSerialConsole [
    "console=ttyS0,115200"
    "console=tty1"
  ];

  networking.hostName = hostname;

  # Enable nix flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  nix.settings = {
    trusted-users = [
      "root"
      "@wheel"
    ];
    substituters = [ "https://cache.nixos.org" ];
    trusted-public-keys = [ "systems:tvbHIThn7MAwvgMSiYR3ULVlL6cBrA40afqGuextnNQ=" ];
    download-buffer-size = 524288000;
  };

  nixpkgs.overlays = [
    customPackageOverlay
  ];

  system.stateVersion = stateVersion;

  # QEMU Guest Agent for host-guest communication
  services.qemuGuest.enable = withQemuAgent;

  # Cloud-init for VM provisioning (useful for cloud deployments)
  services.cloud-init = lib.mkIf withCloudInit {
    enable = true;
    network.enable = true;
  };

  # Auto-resize root partition on boot (for dynamic disk sizing)
  boot.growPartition = withGrowpart;

  # Filesystem optimizations for VMs
  fileSystems."/" = lib.mkDefault {
    device = "/dev/vda1";
    fsType = "ext4";
    options = [
      "noatime"
      "nodiratime"
    ];
  };

  # Swap (optional, can be overridden per-host)
  swapDevices = lib.mkDefault [ ];

  # User account
  users.users.deepak = {
    isNormalUser = true;
    home = "/home/deepak";
    description = "Deepak Mallubhotla";
    extraGroups = [
      "wheel"
      "networkmanager"
      "users"
      "smriti"
    ]
    ++ lib.optionals withDocker [ "docker" ];
    shell = pkgs.zsh;
    initialHashedPassword = "$y$j9T$cVagC4LC8iTozPVAW5uE10$vZiit3Ohx/fwA87p0C.9tzfz0D3ytec.hClUvOjnjF1";
    # Allow SSH key auth (add your keys here or via cloud-init)
    openssh = {
      authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC+yAxaiQ+98tfV2aAkwDVvWzEz5UCnkunrXzSkG8omp dmallubhotla@gmail.com"
      ];
    };
  };

  programs.zsh.enable = true;

  # Essential system packages
  environment.systemPackages =
    with pkgs;
    [
      wget
      vim
      git
      pinentry-curses
      gnupg
      tailscale
      # VM-specific tools
      cloud-utils # for growpart
      parted
    ]
    ++ [
      inputs.openclaw-image.packages.${pkgs.system}.openclaw
    ];

  # Fonts
  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    powerline-fonts
    custom-fonts.custom-fonts
  ];

  # GPG agent
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
    enableSSHSupport = true;
  };

  # Networking
  networking.networkmanager.enable = true;
  networking.useDHCP = lib.mkDefault true;

  # SSH server for remote access
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Tailscale
  services.tailscale.enable = true;
  services.tailscale.port = 62532;

  # Firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      18789
    ];
    allowedUDPPorts = [ 62532 ];
  };

  # Timezone
  time.timeZone = "America/Chicago";

  # Openclaw environment variables for deepak user
  environment.sessionVariables = {
    OPENCLAW_CONFIG_PATH = "/var/lib/smriti/config/openclaw.json";
    OPENCLAW_STATE_DIR = "/var/lib/smriti";
  };

  # Docker (optional)
  virtualisation.docker = lib.mkIf withDocker {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  security.wrappers = lib.mkIf withDocker {
    docker-rootlesskit = {
      owner = "root";
      group = "root";
      capabilities = "cap_net_bind_service+ep";
      source = "${pkgs.rootlesskit}/bin/rootlesskit";
    };
  };

  # Documentation
  documentation = {
    dev.enable = true;
    man.generateCaches = true;
    nixos.enable = true;
  };

  # Service account for openclaw gateway
  users.users.smriti = {
    isSystemUser = true;
    group = "smriti";
    extraGroups = [ "users" ];
    home = "/var/lib/smriti";
    homeMode = "750";
    createHome = true;
    shell = pkgs.zsh; # nologin
    packages =
      with pkgs;
      [
        # Add user-specific packages here
        gh
        python3
        uv
        just
        tmux
        jq
      ]
      ++ (with nixpkgs-unstable; [
        claude-code
      ]);
  };

  users.groups.smriti = { };

  # Openclaw gateway service
  systemd.services.openclaw-gateway = {
    description = "OpenClaw Gateway";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    environment = {
      OPENCLAW_CONFIG_PATH = "/var/lib/smriti/config/openclaw.json";
      OPENCLAW_STATE_DIR = "/var/lib/smriti";
    };

    serviceConfig = {
      Type = "simple";
      User = "smriti";
      Group = "smriti";
      WorkingDirectory = "/var/lib/smriti";
      ExecStart = "${
        inputs.openclaw-image.packages.${pkgs.system}.openclaw
      }/bin/openclaw gateway --bind lan --port 18789 --allow-unconfigured";
      Restart = "on-failure";
      RestartSec = 10;

      # Secrets via environment file (create /var/lib/smriti/secrets.env with GITHUB_PAT and OPENCLAW_GATEWAY_TOKEN)
      EnvironmentFile = "/var/lib/smriti/smriti.env";

      # Hardening
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      ReadWritePaths = [ "/var/lib/smriti" ];
    };
  };

}

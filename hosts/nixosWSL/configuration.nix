{ lib, pkgs, config, modulesPath, ... }:

with lib;
let
  syschdemd = import ./syschdemd.nix { inherit lib pkgs config defaultUser; };
  nixos-wsl = import ./nixos-wsl;
in
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"

    nixos-wsl.nixosModules.wsl
  ];

  networking.hostName = "nixosWSL"; # Define your hostname.
  time.timeZone = "America/Chicago";

  wsl = {
    enable = true;
    automountPath = "/mnt";
    defaultUser = "deepak";
    startMenuLaunchers = true;

    # Enable integration with Docker Desktop (needs to be installed)
    # docker.enable = true;
  };

  users.users.deepak = {
    isNormalUser = true;
    home = "/home/deepak";
    description = "Deepak Mallubhotla";
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
  };

  environment.systemPackages = with pkgs; [
    wget vim
    git
  ];

  # Enable nix flakes
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  nix.settings = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://dmallubhotla-testing-1.cachix.org"
      "https://cache.nixos.org/"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "dmallubhotla-testing-1.cachix.org-1:6Xc9n6kRtYCP8Sofhs4WHM5lYz9cDUgObe3USePVX1s="
    ];
  };
}

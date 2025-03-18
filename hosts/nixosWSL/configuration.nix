{
  pkgs,
  customPackageOverlay,
  modulesPath,
  ...
}:

let
  custom-fonts = import ../../fonts { inherit pkgs; };
in
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"

  ];

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    defaultUser = "deepak";
    startMenuLaunchers = true;

    # Enable native Docker support
    # docker-native.enable = true;

    # Enable integration with Docker Desktop (needs to be installed)
    # docker-desktop.enable = true;
    nativeSystemd = true;

    wslConf.interop.appendWindowsPath = false;

  };

  networking.hostName = "nixosWSL"; # Define your hostname.

  # Enable nix flakes
  # nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  nixpkgs.overlays = [
    customPackageOverlay
  ];

  system.stateVersion = "22.05";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.deepak = {
    isNormalUser = true;
    home = "/home/deepak";
    description = "Deepak Mallubhotla";
    extraGroups = [
      "wheel"
      "networkmanager"
    ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  # default packages because otherwise configuration is a nightmare!
  environment.systemPackages = with pkgs; [
    wget
    vim
    git
    pinentry
    pinentry-curses
    gnupg
    tailscale
  ];

  # Fix of WSL issue
  environment.noXlibs = false;

  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    powerline-fonts
    custom-fonts.custom-fonts
  ];

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-qt;
    enableSSHSupport = true;
  };

  services.tailscale.enable = true;

  # Optional (default: 41641):
  services.tailscale.port = 62532;

}

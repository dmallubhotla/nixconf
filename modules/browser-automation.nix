# Browser Automation Module
# Provides Playwright and associated browsers for web automation tasks
#
# Usage:
#   imports = [ ../modules/browser-automation.nix ];
#   services.browserAutomation.enable = true;
#
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.browserAutomation;
in
{
  options.services.browserAutomation = {
    enable = mkEnableOption "browser automation with Playwright";

    user = mkOption {
      type = types.str;
      default = "deepak";
      description = "User to configure browser automation for";
    };

    browsers = mkOption {
      type = types.enum [ "chromium" "all" ];
      default = "chromium";
      description = ''
        Which browsers to install.
        - "chromium": Only Chromium (recommended, ~500MB)
        - "all": Chromium, Firefox, and WebKit (~1.5GB)
      '';
    };

    fonts = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [ liberation_ttf dejavu_fonts ];
      description = "Fonts to install for proper web page rendering";
    };

    enableCache = mkOption {
      type = types.bool;
      default = true;
      description = "Create a dedicated cache directory for Playwright data";
    };
  };

  config = mkIf cfg.enable {
    # Install Playwright driver
    environment.systemPackages = with pkgs; [
      playwright-driver
      playwright-driver.browsers
    ];

    # Install fonts for proper rendering
    fonts.packages = cfg.fonts;

    # Set environment variable for browser location
    environment.sessionVariables = {
      PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
    };

    # Optional: Create cache directory
    systemd.tmpfiles.rules = mkIf cfg.enableCache [
      "d /var/cache/playwright 0755 ${cfg.user} users -"
    ];

    # Helpful for debugging
    environment.variables = {
      # Make Playwright more verbose in case of issues
      DEBUG = mkDefault "";
    };
  };

  meta = {
    maintainers = [ ];
    doc = ./browser-automation.md;
  };
}

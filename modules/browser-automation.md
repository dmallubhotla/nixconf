# Browser Automation Module

Provides Playwright and Chromium/Firefox/WebKit browsers for web automation and testing.

## Quick Start

```nix
# In your host configuration (e.g., hosts/commonWSL-configuration.nix)
{
  imports = [ ../modules/browser-automation.nix ];
  
  services.browserAutomation.enable = true;
}
```

## Options

### `services.browserAutomation.enable`
- **Type**: boolean
- **Default**: `false`
- **Description**: Enable browser automation support

### `services.browserAutomation.user`
- **Type**: string
- **Default**: `"deepak"`
- **Description**: User account for which to configure browser automation

### `services.browserAutomation.browsers`
- **Type**: enum `[ "chromium" "all" ]`
- **Default**: `"chromium"`
- **Description**: Which browsers to install
  - `"chromium"`: Only Chromium (~500MB)
  - `"all"`: Chromium, Firefox, and WebKit (~1.5GB)

### `services.browserAutomation.fonts`
- **Type**: list of packages
- **Default**: `[ pkgs.liberation_ttf pkgs.dejavu_fonts ]`
- **Description**: Fonts to install for proper web page rendering

### `services.browserAutomation.enableCache`
- **Type**: boolean
- **Default**: `true`
- **Description**: Create a dedicated cache directory at `/var/cache/playwright`

## Examples

### Minimal Configuration
```nix
{
  imports = [ ../modules/browser-automation.nix ];
  services.browserAutomation.enable = true;
}
```

### Custom Configuration
```nix
{
  imports = [ ../modules/browser-automation.nix ];
  
  services.browserAutomation = {
    enable = true;
    user = "developer";
    browsers = "all";  # Install all browsers
    fonts = with pkgs; [
      liberation_ttf
      dejavu_fonts
      noto-fonts
      noto-fonts-emoji
    ];
    enableCache = true;
  };
}
```

## Usage

After enabling this module and rebuilding your system:

```bash
# Check installation
playwright --version

# Environment variable should be set
echo $PLAYWRIGHT_BROWSERS_PATH

# Run a simple test
playwright codegen https://example.com
```

## What This Module Provides

1. **Playwright CLI**: `playwright` command for browser automation
2. **Browsers**: Pre-built browser binaries (Chromium, optionally Firefox/WebKit)
3. **Fonts**: Essential fonts for proper web page rendering
4. **Environment**: `PLAYWRIGHT_BROWSERS_PATH` set correctly
5. **Cache** (optional): Dedicated directory for Playwright data

## Disk Space Requirements

- **Chromium only**: ~500MB
- **All browsers**: ~1.5GB

Browsers are stored in the Nix store, so they're shared across the system and cleaned up with `nix-collect-garbage` when not in use.

## Troubleshooting

### Browsers not found
If you get "Browsers not found" errors:
```bash
# Check environment variable
echo $PLAYWRIGHT_BROWSERS_PATH

# Should point to something like:
# /nix/store/...-playwright-driver-browsers-1.40.1
```

### Re-login after installation
Environment variables are set at login time. After enabling this module:
```bash
sudo nixos-rebuild switch
# Then logout and login, or:
source /etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh
```

### Font rendering issues
If web pages don't render correctly, add more fonts:
```nix
services.browserAutomation.fonts = with pkgs; [
  liberation_ttf
  dejavu_fonts
  noto-fonts
  noto-fonts-emoji
  noto-fonts-cjk
];
```

## Integration with OpenClaw

This module is designed to support OpenClaw's browser automation features. When running OpenClaw:

```bash
# The environment is already configured
openclaw gateway

# Or in Docker, mount the nix store:
docker run -v /nix:/nix -e PLAYWRIGHT_BROWSERS_PATH=$PLAYWRIGHT_BROWSERS_PATH ...
```

## See Also

- [Playwright Documentation](https://playwright.dev/)
- [NixOS Playwright Package](https://search.nixos.org/packages?query=playwright)
- Main proposal: `../BROWSER_CONFIG_MIGRATION.md`

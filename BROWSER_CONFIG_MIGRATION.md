# Browser Configuration Migration Proposal

**Date**: 2026-02-20  
**Author**: Subagent (browser-config-migration)  
**Status**: Proposal for Review  

## Executive Summary

This document proposes migrating the browser configuration (Playwright + Chromium) from the `openclaw-image` Docker container build to the `nixconf` NixOS system configuration, enabling browser automation capabilities on NixOS hosts.

---

## Current State Analysis

### openclaw-image Configuration

**Location**: `/var/lib/smriti/workspace/projects/openclaw-image/packages/openclaw-image.nix`

**Browser-related packages included:**
1. `playwright-driver` - Framework for web testing and automation
2. `playwright-driver.browsers` - Pre-built Chromium/Firefox/WebKit browsers
3. `liberation_ttf` - Fonts for proper page rendering
4. `dejavu_fonts` - Additional font coverage

**Environment configuration:**
```nix
Env = [
  "PLAYWRIGHT_BROWSERS_PATH=${playwright-driver.browsers}"
  # ... other env vars
];
```

**Why this matters:**
- Playwright requires browsers to be available at a specific path
- The `PLAYWRIGHT_BROWSERS_PATH` env var tells Playwright where to find them
- Fonts are essential for web page rendering to work correctly
- This is currently only available inside the Docker container

### nixconf Structure

**Current organization:**
```
nixconf/
├── flake.nix                    # Main flake entry point
├── hosts/
│   ├── hosts.nix               # Host definitions
│   ├── commonWSL-configuration.nix  # Shared WSL config
│   ├── nixosEggYoke/           # Host-specific configs
│   └── nixosWSL/
├── home/
│   └── deepak/home.nix         # Home-manager configuration
├── overlays/
│   └── default.nix             # Custom package overlays
└── fonts/
    └── default.nix             # Font configuration
```

**Key observations:**
- Uses stable nixpkgs (`nixos-25.11`) as base
- Has overlay system for custom packages
- Uses Home Manager for user-level config
- Already includes Docker support (rootless)
- No existing modules directory (we created one)

---

## Migration Options

### Option 1: NixOS Module (Recommended)

**Create**: `modules/browser-automation.nix`

**Approach**: Create a reusable NixOS module that can be optionally enabled per-host.

**Pros:**
- Clean separation of concerns
- Can be enabled/disabled per host
- Reusable across different configurations
- Follows NixOS best practices
- Easy to test and maintain

**Cons:**
- Slightly more complex initial setup
- Need to wire into hosts.nix

**Implementation sketch:**
```nix
# modules/browser-automation.nix
{ config, lib, pkgs, ... }:

with lib;

{
  options.services.browserAutomation = {
    enable = mkEnableOption "browser automation with Playwright";
    
    user = mkOption {
      type = types.str;
      default = "deepak";
      description = "User to configure browser automation for";
    };
  };

  config = mkIf config.services.browserAutomation.enable {
    environment.systemPackages = with pkgs; [
      playwright-driver
      playwright-driver.browsers
    ];

    fonts.packages = with pkgs; [
      liberation_ttf
      dejavu_fonts
    ];

    environment.sessionVariables = {
      PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
    };
  };
}
```

**Usage in host config:**
```nix
# hosts/commonWSL-configuration.nix or specific host
{
  imports = [ ../modules/browser-automation.nix ];
  
  services.browserAutomation.enable = true;
}
```

---

### Option 2: Home Manager Module

**Create**: `home/modules/browser-automation.nix`

**Approach**: Make it a user-level configuration via Home Manager.

**Pros:**
- User-level configuration (doesn't require root/rebuild)
- Can be different per user
- Better for dev tools

**Cons:**
- Browsers require significant disk space (better at system level)
- Home Manager might rebuild unnecessarily
- Less suitable for system services that need browsers

**Implementation sketch:**
```nix
# home/modules/browser-automation.nix
{ config, lib, pkgs, ... }:

with lib;

{
  options.programs.browserAutomation = {
    enable = mkEnableOption "browser automation with Playwright";
  };

  config = mkIf config.programs.browserAutomation.enable {
    home.packages = with pkgs; [
      playwright-driver
      playwright-driver.browsers
    ];

    home.sessionVariables = {
      PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
    };
  };
}
```

---

### Option 3: Direct Integration (Not Recommended)

**Approach**: Add packages directly to `commonWSL-configuration.nix` or `home.nix`.

**Pros:**
- Simplest implementation
- No new files needed

**Cons:**
- No modularity
- Affects all hosts (even those that don't need it)
- Harder to maintain/disable
- Violates separation of concerns

---

### Option 4: Overlay + System Package (Alternative)

**Approach**: Create a custom package in overlays that bundles everything.

**Pros:**
- Single package to install
- Can version together
- Good for distribution

**Cons:**
- More complex than needed for this use case
- Playwright already well-packaged in nixpkgs
- Overkill for simple configuration

---

## Recommendation: Option 1 (NixOS Module)

**Rationale:**
1. **System-level concern**: Browser automation is often used by system services (like OpenClaw gateway)
2. **Resource sharing**: Large browser binaries benefit from system-level installation
3. **Modularity**: Easy to enable/disable per host
4. **Standard practice**: Follows NixOS module conventions
5. **Future-proof**: Easy to extend with additional options (browser selection, versions, etc.)

---

## Implementation Plan

### Step 1: Create the Module

```bash
# Already on branch: feature/browser-config-migration
mkdir -p modules
# Create modules/browser-automation.nix (see Option 1 above)
```

### Step 2: Wire into Flake

Edit `flake.nix` to make the module available:
```nix
# flake.nix
{
  # ... existing code ...
  
  nixosModules = {
    browserAutomation = import ./modules/browser-automation.nix;
  };
  
  # ... rest of config ...
}
```

### Step 3: Enable in Host Config

Choose which hosts need it. For example:
```nix
# hosts/commonWSL-configuration.nix
{
  imports = [
    ../modules/browser-automation.nix
  ];
  
  services.browserAutomation.enable = true;
}
```

Or enable selectively:
```nix
# hosts/hosts.nix - in specific host definition
modules = [
  # ... existing modules ...
  ../modules/browser-automation.nix
  { services.browserAutomation.enable = true; }
];
```

### Step 4: Test

```bash
# Build the configuration
cd /var/lib/smriti/workspace/projects/nixconf
nixos-rebuild build --flake .#nixosEggYoke

# Check that playwright-driver is included
nix-store -qR result | grep playwright

# Test (after applying)
echo $PLAYWRIGHT_BROWSERS_PATH
playwright --version
```

### Step 5: Documentation

Update `README.md` with:
- Available modules
- How to enable browser automation
- Environment variables set

---

## Advanced Options (Future Enhancements)

Once basic module is working, consider:

### 1. Browser Selection
```nix
options.services.browserAutomation.browsers = {
  chromium = mkEnableOption "Chromium";
  firefox = mkEnableOption "Firefox";
  webkit = mkEnableOption "WebKit";
};
```

### 2. Headless Display Server
```nix
# For running browsers headless
services.xserver.enable = mkDefault false;
programs.xwayland.enable = mkIf config.services.browserAutomation.enable true;
```

### 3. Font Customization
```nix
options.services.browserAutomation.fonts = mkOption {
  type = types.listOf types.package;
  default = with pkgs; [ liberation_ttf dejavu_fonts ];
  description = "Fonts to install for browser rendering";
};
```

### 4. Cache Directory
```nix
# Dedicated cache for browser data
systemd.tmpfiles.rules = [
  "d /var/cache/playwright 0755 ${config.services.browserAutomation.user} users -"
];
```

---

## Migration Checklist

- [x] Analyze openclaw-image browser configuration
- [x] Study nixconf structure
- [x] Create feature branch `feature/browser-config-migration`
- [ ] Implement `modules/browser-automation.nix`
- [ ] Update `flake.nix` to expose module
- [ ] Enable in appropriate host(s)
- [ ] Test build
- [ ] Test runtime (playwright commands)
- [ ] Update documentation
- [ ] Create PR for review
- [ ] Merge after approval

---

## Files to Create/Modify

### New Files:
1. `modules/browser-automation.nix` - Main module implementation
2. `modules/default.nix` (optional) - Module index

### Modified Files:
1. `flake.nix` - Add module to nixosModules
2. `hosts/commonWSL-configuration.nix` OR specific host config - Enable the module
3. `README.md` - Document the new module

### No Changes Needed:
- `overlays/default.nix` - Not needed for this approach
- `home/deepak/home.nix` - System-level is better choice

---

## Questions for Review

1. **Which hosts should enable this?** All WSL hosts, or just specific ones?
2. **Should this be system-level or home-manager level?** (Recommend system-level)
3. **Do we need all three browsers (Chromium, Firefox, WebKit)?** Or just Chromium?
4. **Font selection**: Are liberation_ttf + dejavu_fonts sufficient, or add more?
5. **Should we version-pin playwright**, or use whatever nixpkgs provides?

---

## Risk Assessment

**Low Risk:**
- Adding packages to system configuration
- Creating new module (doesn't affect existing config)
- Feature branch (isolated from master)

**Medium Risk:**
- Disk space: Playwright browsers are ~500MB-1GB
- Build time: First build will take longer

**Mitigation:**
- Make module opt-in (not enabled by default)
- Document disk space requirements
- Consider using Nix binary cache for faster builds

---

## Next Steps

1. **Review this proposal** with Deepak
2. **Decide on**:
   - Which option to implement (recommend Option 1)
   - Which hosts should enable it
   - Any customizations needed
3. **Implementation**: 
   - If approved as-is, I can implement Option 1
   - If changes needed, discuss and revise
4. **Testing plan**: How to validate it works
5. **Deployment**: When to merge to master

---

## References

- **openclaw-image**: `/var/lib/smriti/workspace/projects/openclaw-image/packages/openclaw-image.nix`
- **nixconf**: `/var/lib/smriti/workspace/projects/nixconf`
- **Playwright in nixpkgs**: `pkgs.playwright-driver`
- **NixOS module system**: https://nixos.org/manual/nixos/stable/#sec-writing-modules

---

**Branch**: `feature/browser-config-migration`  
**Ready for**: Review and discussion

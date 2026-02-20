# Integration Example

This document shows exactly how to integrate the browser automation module into your nixconf.

## Option A: Enable for All WSL Hosts

Edit `hosts/commonWSL-configuration.nix`:

```nix
{
  pkgs,
  customPackageOverlay,
  withDocker,
  stateVersion,
  modulesPath,
  hostname,
  ...
}:
let
  custom-fonts = import ../fonts { inherit pkgs; };
in
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"
    ../modules/browser-automation.nix  # <-- ADD THIS LINE
  ];

  # ... existing wsl config ...

  # Enable browser automation for all WSL hosts
  services.browserAutomation.enable = true;  # <-- ADD THIS LINE

  # ... rest of existing configuration ...
}
```

## Option B: Enable for Specific Hosts Only

Edit `hosts/hosts.nix` to enable it per-host:

```nix
{
  "nixosEggYoke" = inputs.nixpkgs-stable.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit customPackageOverlay;
      inherit nixpkgs-unstable;
      hostname = "nixosEggYoke";
      stateVersion = "22.05";
      withDocker = true;
    };
    modules = [
      (
        { ... }:
        {
          nix.registry.nixpkgs.flake = inputs.nixpkgs-stable;
        }
      )
      ./commonWSL-configuration.nix
      
      # Add browser automation module
      ../modules/browser-automation.nix
      
      # Enable it for this host
      {
        services.browserAutomation = {
          enable = true;
          user = "deepak";
        };
      }
      
      inputs.sops-nix.nixosModules.sops
      inputs.homeManager-stable.nixosModules.home-manager
      # ... rest of modules ...
    ];
  };
}
```

## Option C: Via flake.nix (Most Flexible)

If you want to expose it as a flake module:

```nix
# flake.nix
{
  outputs = {
    self,
    systems,
    nixpkgs,
    ...
  }@inputs:
  let
    # ... existing let bindings ...
  in
  {
    # Add this section
    nixosModules = {
      browserAutomation = import ./modules/browser-automation.nix;
      default = import ./modules;  # All modules
    };

    nixosConfigurations = (
      import ./hosts/hosts.nix {
        inherit inputs;
        inherit customPackageOverlay;
      }
    );

    # ... rest of outputs ...
  };
}
```

Then in hosts:
```nix
modules = [
  self.nixosModules.browserAutomation
  { services.browserAutomation.enable = true; }
];
```

## Recommended Approach

**For your setup, I recommend Option A** (enable in commonWSL-configuration.nix):

1. It's the simplest
2. Both your WSL hosts likely benefit from browser automation
3. Easy to disable later if needed
4. Follows your existing pattern (Docker is enabled this way)

## Testing After Integration

```bash
# Build the configuration
cd /var/lib/smriti/workspace/projects/nixconf
sudo nixos-rebuild build --flake .#nixosEggYoke

# Apply it
sudo nixos-rebuild switch --flake .#nixosEggYoke

# Test
playwright --version
echo $PLAYWRIGHT_BROWSERS_PATH

# Try a simple command
playwright codegen https://example.com
```

## Rollback (if needed)

```bash
# NixOS makes it easy to rollback
sudo nixos-rebuild switch --rollback
```

## Disk Space Note

Before applying, check available space:
```bash
df -h /nix
```

You'll need ~500MB for Chromium (or ~1.5GB for all browsers).

## Next Steps After Integration

1. Test the basic installation
2. Run OpenClaw with browser automation
3. Consider adding to other hosts if needed
4. Update your documentation

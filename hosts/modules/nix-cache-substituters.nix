# Extra Nix cache substituters (pull-side, system-level).
#
# Auto-imported by mkHost whenever `withSops = true` (which is the default
# for WSL/Proxmox/Desktop builders). Currently wires FlakeHub Cache and
# carries netrc credentials for any other private caches (e.g. attic) via
# a single system-level netrc deployed by sops. Add more
# `extra-substituters` here as new caches come online; keep their
# credentials in the same netrc.
#
# Identity: system sops reuses the user's age key at
# ~/.config/sops/age/keys.txt -- the same one user-level sops uses for
# home/deepak/secrets.yaml. sops-nix activation runs as root and root can
# read 0600 user-owned files, so no separate machine identity is needed.
#
# Prereq: any withSops host must have:
#   1. ~/.config/sops/age/keys.txt present for deepak (i.e. user-level
#      sops works) -- see docs/sops-onboard.md.
#   2. Its age recipient listed in ../secrets/.sops.yaml AND included in
#      the system.yaml creation_rules group.
#   3. The `nix-netrc` key populated in ../secrets/system.yaml (one literal
#      block holding every netrc `machine ...` line you need).
{ config, ... }:
{
  sops = {
    age.keyFile = "/home/deepak/.config/sops/age/keys.txt";
    secrets.nix-netrc = {
      sopsFile = ../secrets/system.yaml;
      restartUnits = [ "nix-daemon.service" ];
    };
  };

  nix.settings = {
    extra-substituters = [
      "https://cache.flakehub.com"
      "https://attic.i.hruday.me/homelab"
    ];

    # FlakeHub rotates and appends keys over time. Run `fh login` periodically
    # and copy the CURRENT full set it emits into this list -- a stale or
    # partial list silently breaks signature verification.
    extra-trusted-public-keys = [
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
      "cache.flakehub.com-4:Asi8qIv291s0aYLyH6IOnr5Kf6+OF14WVjkE6t3xMio="
      "homelab:rhI8NPdqQ5lR/WwO8QvYR7z/qT5bWQwhL3XIgZ55R9w="
    ];

    netrc-file = config.sops.secrets.nix-netrc.path;

    # Fail fast so an unreachable cache can't hang a build.
    connect-timeout = 5;
  };
}

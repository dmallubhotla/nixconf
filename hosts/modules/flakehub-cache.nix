# FlakeHub Cache substituter (pull-side, system-level).
#
# Imported only when the host builder is called with `withFlakehub = true`.
# The host builder also forces `withSops = true` so the NixOS sops-nix module
# is loaded. Eval is identical to the no-flakehub case for hosts that don't
# opt in.
#
# Identity: system sops reuses the user's age key at
# ~/.config/sops/age/keys.txt -- the same one user-level sops uses for
# home/deepak/secrets.yaml. sops-nix activation runs as root and root can
# read 0600 user-owned files, so no separate machine identity is needed.
#
# Bootstrap (one-time per host):
#   1. Make sure ~/.config/sops/age/keys.txt exists for deepak on this host
#      (i.e. user-level sops works). If it doesn't, see docs/sops-onboard.md.
#   2. Generate a FlakeHub token (FlakeHub UI -> Tokens) and edit
#      ../secrets/system.yaml with `sops`. Put the three netrc lines under
#      the `flakehub-netrc` key as a literal block.
#   3. Flip `withFlakehub = true` on the host in hosts/hosts.nix and rebuild.
{ config, ... }:
{
  sops = {
    age.keyFile = "/home/deepak/.config/sops/age/keys.txt";
    secrets.flakehub-netrc = {
      sopsFile = ../secrets/system.yaml;
      restartUnits = [ "nix-daemon.service" ];
    };
  };

  nix.settings = {
    extra-substituters = [ "https://cache.flakehub.com" ];

    # FlakeHub rotates and appends keys over time. Run `fh login` periodically
    # and copy the CURRENT full set it emits into this list -- a stale or
    # partial list silently breaks signature verification.
    extra-trusted-public-keys = [
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
      "cache.flakehub.com-4:Asi8qIv291s0aYLyH6IOnr5Kf6+OF14WVjkE6t3xMio="
    ];

    netrc-file = config.sops.secrets.flakehub-netrc.path;
  };
}

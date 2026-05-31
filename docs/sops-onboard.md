# sops onboarding

This repo runs two sops setups in parallel. Each has its own `.sops.yaml`,
secrets file, and decryption key source.

| Scope               | Secrets file              | Config                  | Decrypts with                 |
| ------------------- | ------------------------- | ----------------------- | ----------------------------- |
| user (home-manager) | `home/deepak/secrets.yaml` | `home/deepak/.sops.yaml` | `~/.config/sops/age/keys.txt` |
| system (NixOS)      | `hosts/secrets/system.yaml` | `hosts/secrets/.sops.yaml` | `~/.config/sops/age/keys.txt` |

The split is forced by FlakeHub: nix-daemon (root) needs to read its netrc,
and user-scoped sops can't write to root-owned paths. So we have two
secrets files and two `.sops.yaml`s, but they share the **same age
identity** — the per-machine user key at `~/.config/sops/age/keys.txt`.

Why share the identity: sops-nix activation runs as root, and root can
read the user's 0600 key file without ceremony. The user/system distinction
becomes just "which path the decrypted file lands at" (`/run/user/...` vs
`/run/secrets/...`), not a separate identity model. Recipients in both
`.sops.yaml`s should match.

Bootstrap cost is the same as user sops today: place
`~/.config/sops/age/keys.txt` once per host. No new key material per host
beyond what user sops already requires.

---

## Onboarding a new host

### User-level (home-manager) sops

Needed if the host runs home-manager and you want it to be able to decrypt
shared user secrets (Anthropic API key, etc.).

1. On the new host, generate or copy in the user age key at
   `~/.config/sops/age/keys.txt`. If you're reusing your existing key, scp it
   from another machine; if generating fresh, run:
   ```
   nix shell nixpkgs#age -c age-keygen -o ~/.config/sops/age/keys.txt
   ```
2. Copy the public recipient line from the comment at the top of that file.
3. Add the recipient to `home/deepak/.sops.yaml` as a new alias and include
   it in the `creation_rules` age group:
   ```yaml
   keys:
     - &newhost age1...
   creation_rules:
     - path_regex: secrets.yaml$
       key_groups:
         - age:
             - *nixosEggYoke
             - *nixosWSL
             - *newhost
   ```
4. Re-encrypt to the updated recipient list:
   ```
   sops updatekeys home/deepak/secrets.yaml
   ```
5. Commit and rebuild — the new host can now read the existing secrets.

### System-level (NixOS) sops — for FlakeHub etc.

System sops gets pulled in automatically for any host built with
`withSops = true` (the default for WSL/Proxmox/Desktop builders). There's
no separate opt-in flag — if system sops is on, the host expects to be
able to decrypt `hosts/secrets/system.yaml`. Reuses the user age key, so
no new key material per host beyond what user-level sops already requires.

1. Make sure user-level sops onboarding (above) is done first. The system
   sops module decrypts with the same key.
2. Add the host's user age recipient to `hosts/secrets/.sops.yaml`. Use
   the same `age1...` value (and alias) that's already in
   `home/deepak/.sops.yaml`:
   ```yaml
   keys:
     - &newhost age1...    # same value as in home/deepak/.sops.yaml
   creation_rules:
     - path_regex: system\.yaml$
       key_groups:
         - age:
             - *newhost
             # ...existing entries
   ```
3. Re-encrypt the system secrets file:
   ```
   sops updatekeys hosts/secrets/system.yaml
   ```
   (Skip if `system.yaml` doesn't exist yet — see "Adding a new secret"
   below for the create case.)
4. Rebuild. `nix-cache-substituters.nix` is auto-imported by mkHost when
   `withSops = true`, so no host-level flag to flip.

---

## Adding a new secret

### User-level

1. Edit the file in place — sops will prompt for the encrypted view:
   ```
   sops home/deepak/secrets.yaml
   ```
2. Add the key/value pair. Save and exit.
3. Declare it in `home/deepak/sops.nix` so home-manager exposes it:
   ```nix
   sops.secrets.newkey = { };
   ```
4. Reference `config.sops.secrets.newkey.path` (or use `.sopsFile` patterns)
   from the home-manager modules that consume it.

### System-level

1. If `hosts/secrets/system.yaml` doesn't exist yet, create it:
   ```
   sops hosts/secrets/system.yaml
   ```
   sops will pick up the recipients from `hosts/secrets/.sops.yaml` and
   encrypt to all of them on save.
2. Add the key. For multi-line secrets (e.g. netrc body) use a literal block.
   The `nix-netrc` key is shared across every cache that needs auth — add
   one `machine` line per host:
   ```yaml
   nix-netrc: |
     machine cache.flakehub.com login flakehub password flakehub1_...
     machine api.flakehub.com login flakehub password flakehub1_...
     machine flakehub.com login flakehub password flakehub1_...
     machine attic.baklava login ... password ...
   ```
3. Declare the secret in the NixOS module that needs it. For the netrc
   this is already done in `hosts/modules/nix-cache-substituters.nix`;
   for a new secret, follow the same pattern:
   ```nix
   sops.secrets.my-secret = {
     sopsFile = ../secrets/system.yaml;
     restartUnits = [ "consumer.service" ];
   };
   ```
4. Reference `config.sops.secrets.my-secret.path` from the service config.

---

## Rotating recipients

When you add or remove a host alias in either `.sops.yaml`, the existing
encrypted files don't update automatically. Re-key them:

```
sops updatekeys home/deepak/secrets.yaml
sops updatekeys hosts/secrets/system.yaml
```

Commit the re-encrypted files. The plaintext doesn't change — only the
header section that lists the recipients each blob is encrypted to.

## Rotating the FlakeHub token

1. Generate a new token in the FlakeHub UI (Tokens page) and revoke the old
   one.
2. `sops hosts/secrets/system.yaml`, replace the netrc body, save.
3. Commit and rebuild. The `restartUnits = [ "nix-daemon.service" ]` on the
   secret means nix-daemon picks up the new netrc automatically.

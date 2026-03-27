# executes default, set to rebuilding current flake as test
default:
    just --list

# does a nixos-rebuild test of current flake
install:
    nixos-rebuild test --flake . --sudo

# run nix flake check
test:
    nix flake check

fmt:
    nix fmt

update:
    nix flake update

# update a remote NixOS host by IP address via flake
remote-update ip hostname:
    nixos-rebuild switch --flake .#{{ hostname }} --target-host deepak@{{ ip }} --sudo --ask-sudo-password

# Build a bootable installer ISO for a bare-metal host (e.g. shannon).
# Uses the packages.<system>.<hostname>-iso flake output, which is a NixOS installer
# with useful packages (git, parted, ipmitool) and the proxmox-nixos cache
# pre-configured so nixos-install is fast.
#
# Usage:
#   just build-iso shannon          # build installer ISO for shannon
#
# Output: result/iso/nixos-*.iso (path printed after build)
# Flash with: dd if=$(ls result/iso/nixos-*.iso) of=/dev/sdX bs=4M status=progress
#
# After booting the ISO:
#   1. Partition disks, mount under /mnt (e.g. mount /dev/sda1 /mnt)
#   2. nixos-generate-config --root /mnt
#   3. Copy hosts/shannon/hardware-configuration.nix from the generated output
#   4. nixos-install --flake github:smritibot/nixconf#shannon
#      (or from a local clone: nixos-install --flake /path/to/nixconf#shannon)
build-iso hostname out="./result":
    nix build \
        --out-link {{ out }} \
        '.#packages.x86_64-linux.{{ hostname }}-iso'
    @echo ""
    @echo "ISO built:"
    @ls {{ out }}/iso/nixos-*.iso

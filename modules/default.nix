# Module index
# Import this to get all custom modules at once
#
# Usage in host config:
#   imports = [ ../modules ];
#
{ ... }:

{
  imports = [
    ./browser-automation.nix
    # Add more modules here as they're created
  ];
}

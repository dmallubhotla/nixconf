# treefmt.nix
{ ... }:
{
  projectRootFile = "treefmt.nix";
  settings.global.excludes = [
    "*.toml"
    "*.ttf"
    "*.txt"
  ];

  programs.deadnix.enable = true;
  programs.mdsh.enable = true;
  programs.nixfmt.enable = true;
  programs.shellcheck.enable = true;
  programs.shfmt.enable = true;
  programs.yamlfmt.enable = true;
}

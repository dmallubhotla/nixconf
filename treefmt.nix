# treefmt.nix
{...}: {
  projectRootFile = "treefmt.nix";
  settings.global.excludes = [
    "*.toml"
    "*.ttf"
    "*.txt"
    "*.otf"
    "Jenkinsfile"
    "fonts/out/*"
  ];

  programs.deadnix.enable = true;

  programs.mdsh.enable = true;

  # programs.nixfmt.enable = true;
  # settings.formatter.nixfmt.indent = "	";
  programs.alejandra.enable = true;
  settings.formatter.alejandra.indentation = "Tabs";

  programs.shellcheck.enable = true;

  programs.shfmt.enable = true;
  settings.formatter.shfmt.indent = "\t";

  programs.yamlfmt.enable = true;
  settings.formatter.yamlfmt.indent = 1; # yamlfmt uses number of tab characters for indent
  settings.formatter.yamlfmt.use_tabs = true;

  programs.just.enable = true; # just format uses tabs by default if first line has tabs

  programs.stylua.enable = true; # Already configured for tabs in stylua.toml

  # Formatter specific settings
}

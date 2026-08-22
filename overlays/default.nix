{
  cmp-vimtex,
  spaceport-nvim,
  nomodoro,
  # parrot-nvim,
  inputs,
}:
let
  pluginoverlay =
    _final: prev:
    let
      cmpVimtexPlugin = prev.vimUtils.buildVimPlugin {
        src = cmp-vimtex;
        name = "cmp-vimtex";
        doCheck = false;
      };
      spaceportNvimPlugin = prev.vimUtils.buildVimPlugin {
        src = spaceport-nvim;
        name = "spaceport-nvim";
        doCheck = false;
      };
      nomodoroNvimPlugin = prev.vimUtils.buildVimPlugin {
        src = nomodoro;
        name = "nomodoro";
        doCheck = false;
      };

      # parrotNvimPlugin = prev.vimUtils.buildVimPlugin {
      #   src = parrot-nvim;
      #   name = "parrot-nvim";
      # };

      nvimWebDeviconPlugin = prev.vimUtils.buildVimPlugin {
        src = inputs.nvim-web-devicons;
        name = "nvim-web-devicons";
      };

      herdrPackage = inputs.herdr.packages.${prev.stdenv.hostPlatform.system}.default;

      zshCompletionPlugin = {
        name = "zsh-completions";
        src = inputs.zsh-completions;
      };
    in
    {
      customVimPlugins = {
        cmp-vimtex = cmpVimtexPlugin;
        spaceport-nvim = spaceportNvimPlugin;
        nomodoro = nomodoroNvimPlugin;
        # parrot-nvim = parrotNvimPlugin;
        nvim-web-devicons = nvimWebDeviconPlugin;
      };

      customZshPlugins = {
        zsh-completions = zshCompletionPlugin;
      };

      # Taking the package output rather than herdr.overlays.default, which composes rust-overlay into the whole pkgs set.
      herdr = herdrPackage;
    };
in
{
  overlay = inputs.nixpkgs.lib.composeManyExtensions [
    pluginoverlay
    inputs.hanko.overlays.default
    inputs.kestrel.overlays.default
  ];
}

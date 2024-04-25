{ cmp-vimtex, spaceport-nvim }:
{
  overlay = final: prev:
     let
       cmpVimtexPlugin = prev.vimUtils.buildVimPlugin {
         src = cmp-vimtex;
         name = "cmp-vimtex";
       };
       spaceportNvimPlugin = prev.vimUtils.buildVimPlugin {
         src = spaceport-nvim;
         name = "spaceport-nvim";
       };
     in
     {
       customVimPlugins = { 
         cmp-vimtex = cmpVimtexPlugin;
         spaceport-nvim = spaceportNvimPlugin;
       };
     };
}

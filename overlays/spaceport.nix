{ spaceport-nvim }:
{
  overlay = final: prev:
     let
       spaceportNvimPlugin = prev.vimUtils.buildVimPlugin {
         src = spaceport-nvim;
         name = "spaceport-nvim";
       };
     in
     {
       customVimPlugins = { 
         spaceport-nvim = spaceportNvimPlugin;
       };
     };
}

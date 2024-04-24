{ cmp-vimtex }:
{
  overlay = final: prev:
     let
       cmpVimtexPlugin = prev.vimUtils.buildVimPlugin {
         src = cmp-vimtex;
         name = "cmp-vimtex";
       };
     in
     {
       customVimPlugins = [
         cmpVimtexPlugin
       ];
     };
}

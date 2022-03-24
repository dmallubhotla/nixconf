{ pkgs, config, ...}: {
  
  programs.home-manager.enable = true;
  home.packages = [ 
    pkgs.hello
    (pkgs.writeScriptBin "nixFlakes" ''
      exec ${pkgs.nixUnstable}/bin/nix --experimental-features "nix-command flakes" "$@"
    '')
  ];
  
  home.homeDirectory = "/home/deepak";
  home.username = "deepak";

}

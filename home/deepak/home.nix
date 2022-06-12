{ pkgs, config, ...}: {

  programs.home-manager.enable = true;
  home.packages = [
    pkgs.hello
    (pkgs.writeScriptBin "nixFlakes" ''
      exec ${pkgs.nixUnstable}/bin/nix --experimental-features "nix-command flakes" "$@"
    '')
    pkgs.obsidian
    pkgs.atom
    pkgs.cachix
  ];

  home.homeDirectory = "/home/deepak";
  home.username = "deepak";

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.git = {
    enable = true;
    userName  = "Deepak Mallubhotla";
    userEmail = "dmallubhotla+github@gmail.com";
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      doo="./do.sh";
    };
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
    oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "poetry"
          "themes"
          "emoji-clock"
          "screen"
          "ssh-agent"
        ];
        theme = "random";
    };
    plugins = [
      {
        name = "sd";
        src = pkgs.fetchFromGitHub {
          owner = "ianthehenry";
          repo = "sd";
          rev = "ecd1ab8d3fc3a829d8abfb8bf1e3722c9c99407b";
          sha256 = "0fm1r8w73vaab5r9dj5jdxsfc7pbddxf4dvvasfq8rry2dxaf7sy";
        };
      }
      {
        name = "zsh-z";
        src = pkgs.fetchFromGitHub {
          owner = "agkozak";
          repo = "zsh-z";
          rev = "b5e61d03a42a84e9690de12915a006b6745c2a5f";
          sha256 = "1gsgmsvl1sl9m3yfapx6bp0y15py8610kywh56bgsjf9wxkrc3nl";
        };
      }
    ];
    initExtra = ''
      eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
    '';
  };


}

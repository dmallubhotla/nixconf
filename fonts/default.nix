{ pkgs ? import <nixpkgs> {} }:

let
  custom-fonts = pkgs.stdenvNoCC.mkDerivation {
    pname = "input";
    version = "1.0.2";
    src = ./.;
    dontConfigure = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share
      cp -R out $out/share/fonts
      runHook postInstall
    '';

    meta = {
      description = "Input DJR font";
    };
  };
in
{
  inherit custom-fonts;
}

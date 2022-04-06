{ pkgs ? import <nixpkgs> {} }:

let
  input-font = pkgs.stdenvNoCC.mkDerivation {
    pname = "input";
    version = "1.0.1";
    src = ./.;
    dontConfigure = true;

    installPhase = ''
      runHook preInstall
      cp -R out $out/
      runHook postInstall
    '';

    meta = {
      description = "Input DJR font";
    };
  };
in
{
  inherit input-font;
}

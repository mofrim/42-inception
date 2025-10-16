{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  name = "inception";
  buildInputs = with pkgs; [
    openssl
    bash
  ];
  shellHook = ''
    echo "hi there!"
  '';
}

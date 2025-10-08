{ pkgs ? import <nixpkgs> {} }:
#let
  #pkgs = import (builtins.fetchGit {
    #url = "/home/frido/nix/nixpkgs-fork/";
    #ref = "master";
    # ref = "nixos-24.05";
  #}) {};
#in
pkgs.mkShell {
  name = "inception";
  buildInputs = with pkgs; [
    openssl
  ];
  shellHook = ''
    echo "hi there!"
  '';
}

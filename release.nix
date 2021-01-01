let
  sources = import ./nix/sources.nix {};
  pkgs = import sources.nixpkgs {};
  ncbi-blast = pkgs.callPackage sources.ncbi-blast {};
in
  pkgs.callPackage ./default.nix { inherit ncbi-blast; }

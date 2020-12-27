# Based on:
#   http://nixos.org/nixpkgs/manual/#sec-language-ruby
#   http://blog.arkency.com/2016/04/packaging-ruby-programs-in-nixos

# TODO why doesn't it pick up cat from coreutils? (has to be added to main nix-shell)

let
  # TODO clean this up: upload the blast-nix package and load it with niv
  # TODO and include the v2.2.29 code here instead? this is the only repo that would need it
  defaultBlast = import ../blast-nix/release-2_2_29.nix;
in

{ stdenv, fetchurl, lib, bundlerEnv, ruby, makeWrapper, coreutils
, ncbi-blast ? defaultBlast
}:

# with import ../.;

# TODO coreutils needs to be used in env rather than overall derivation?
let
  version = (import ./gemset.nix).crb-blast.version;
  env = bundlerEnv {
    inherit ruby version;
    name = "crb-blast-${version}-env";
    gemdir = ./.;
    meta = with lib; {
      description = "Conditional Reciprocal Best Blast";
      homepage    = https://github.com/cboursnell/crb-blast;
      license     = with licenses; mit;
      maintainers = with maintainers; [ ];
      platforms   = [ "x86_64-linux" "x86_64-darwin" ];
    };
  };

# TODO why doesn't cat get in the runtime path? and proper ncbi-blast?
in stdenv.mkDerivation {
  inherit env version;
  name         = "crb-blast-${version}";
  buildInputs  = [ makeWrapper ncbi-blast coreutils ];
  phases       = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${env}/bin/crb-blast $out/bin/crb-blast \
      --prefix PATH : "${ncbi-blast}/bin" \
      --prefix PATH : "${coreutils}/bin"
  '';
}

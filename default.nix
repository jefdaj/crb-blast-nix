# Based on:
#   http://nixos.org/nixpkgs/manual/#sec-language-ruby
#   http://blog.arkency.com/2016/04/packaging-ruby-programs-in-nixos

# TODO why doesn't it pick up cat from coreutils? (has to be added to main nix-shell)

{ stdenv, fetchurl, lib, bundlerEnv, ruby, makeWrapper, coreutils
, ncbi-blast
}:

# TODO coreutils needs to be used in env rather than overall derivation?
let
  with_src_2_2_29 = old: rec {
    version="2.2.29";
    name="ncbi-blast-${version}";
    src = if stdenv.hostPlatform.system == "x86_64-darwin"
      then (fetchurl {
        url = "ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.2.29/ncbi-blast-2.2.29+-universal-macosx.tar.gz";
        sha256="00g8pzwx11wvc7zqrxnrd9xad68ckl8agz9lyabmn7h4k07p5yll";
      }) else (fetchurl {
        url = "ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.2.29/ncbi-blast-2.2.29+-x64-linux.tar.gz";
        sha256="1pzy0ylkqlbj40mywz358ia0nq9niwqnmxxzrs1jak22zym9fgpm";
      });
    };
  old-blast = ncbi-blast.overrideDerivation with_src_2_2_29;
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
  buildInputs  = [ makeWrapper old-blast coreutils ];
  phases       = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${env}/bin/crb-blast $out/bin/crb-blast \
      --prefix PATH : "${old-blast}/bin" \
      --prefix PATH : "${coreutils}/bin"
  '';
}

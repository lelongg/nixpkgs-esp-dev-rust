{ version ? "15.0.0-20221201"
, hash ? "sha256-g55a36f0SYLootgoaA9uSqQ13NPR33ZeAvAVsEKGBW8="
, stdenv
, lib
, fetchurl
, makeWrapper
, buildFHSUserEnv
}:

let
  fhsEnv = buildFHSUserEnv {
    name = "xtensa-toolchain-env";
    targetPkgs = pkgs: with pkgs; [ zlib libxml2 ];
    runScript = "";
  };
in

assert stdenv.system == "x86_64-linux";

stdenv.mkDerivation rec {
  pname = "xtensa-llvm-toolchain";
  inherit version;
  src = fetchurl {
    url = "https://github.com/espressif/llvm-project/releases/download/esp-${version}/llvm-esp-${version}-linux-amd64.tar.xz";
    inherit hash;
  };

  buildInputs = [ makeWrapper ];

  phases = [ "unpackPhase" "installPhase" ];

  installPhase = ''
    cp -r . $out
    for FILE in $(ls $out/bin); do
      FILE_PATH="$out/bin/$FILE"
      if [[ -x $FILE_PATH ]]; then
        mv $FILE_PATH $FILE_PATH-unwrapped
        makeWrapper ${fhsEnv}/bin/xtensa-toolchain-env $FILE_PATH --add-flags "$FILE_PATH-unwrapped"
      fi
    done
  '';

  meta = with lib; {
    description = "Xtensa LLVM tool chain";
    homepage = "https://github.com/espressif/llvm-project";
    license = licenses.gpl3;
  };
}


{ version ? "1.82.0.3"
, callPackage
, rust
, lib
, stdenv
, fetchurl
}:
let
  component = import {};
  # Remove keys from attrsets whose value is null.
  removeNulls = set:
    removeAttrs set
      (lib.filter (name: set.${name} == null)
        (lib.attrNames set));
  # FIXME: https://github.com/NixOS/nixpkgs/pull/146274
  toRustTarget = platform:
    if platform.isWasi then
      "${platform.parsed.cpu.name}-wasi"
    else
      rust.toRustTarget platform;
  mkComponentSet = callPackage ./rust/mk-component-set.nix {
    inherit toRustTarget removeNulls;
    # src = 

  };
  mkAggregated = callPackage ./rust/mk-aggregated.nix {};
  
  selComponents = mkComponentSet {
    inherit version;
    renames = {};
    platform = "x86_64-linux";
    srcs = {  
      rustc = fetchurl {
        url = "https://github.com/esp-rs/rust-build/releases/download/v${version}/rust-${version}-x86_64-unknown-linux-gnu.tar.xz";
        hash = "sha256-AQYRuKmxVc5lCceu60oWybjl75iE/mzkmMoVq0yaNbE=";
      };
      rust-src = fetchurl {
        url = "https://github.com/esp-rs/rust-build/releases/download/v${version}/rust-src-${version}.tar.xz";
        hash = "sha256-Vf0Dc9RTm9grIqR/5YKNNoTLQiy5JqI9OJyl+WBaeT0=";
      };
      
    };

  };
  
in
assert stdenv.system == "x86_64-linux";
mkAggregated {
  pname = "rust-xtensa";
  date = "2023-01-25";
  inherit version;
  availableComponents = selComponents;
  selectedComponents = [ selComponents.rustc selComponents.rust-src ];
}


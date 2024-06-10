{ callPackage, fetchurl, flavour, hostPlatform, runtimeShellPackage, stdenvNoCC, zstd }:
let
  common-src = builtins.fromJSON (builtins.readFile ../autogen.json);
  arch =
    if hostPlatform.system == "x86_64-linux" then "" else "-${hostPlatform.system}";
  src = fetchurl common-src."wasm32-wasi-ghc-${flavour}${arch}";
  wasi-sdk = callPackage ./wasi-sdk.nix { };
in
stdenvNoCC.mkDerivation {
  name = "wasm32-wasi-ghc-${flavour}";

  inherit src;

  nativeBuildInputs = [ wasi-sdk zstd ];
  buildInputs = [ runtimeShellPackage ];

  preConfigure = ''
    patchShebangs .
    configureFlags="$configureFlags --build=$system --host=$system $CONFIGURE_ARGS"
  '';

  configurePlatforms = [ ];

  dontBuild = true;
  dontFixup = true;
  strictDeps = true;
}

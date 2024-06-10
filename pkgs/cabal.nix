{ fetchurl, hostPlatform, stdenvNoCC }:
let
  arch =
    if hostPlatform.system == "x86_64-linux" then "" else "-${hostPlatform.system}";
  src = fetchurl
    ((builtins.fromJSON (builtins.readFile ../autogen.json))."cabal${builtins.replaceStrings ["-"] ["_"] arch}");
in
stdenvNoCC.mkDerivation {
  name = "cabal";
  dontUnpack = true;
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    tar xJf ${src} -C $out/bin cabal

    runHook postInstall
  '';
  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/cabal --version
  '';
  allowedReferences = [ ];
}

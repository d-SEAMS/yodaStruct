{
  lib,
  stdenv,
  meson,
  ninja,
  pkg-config,
  eigen,
  blas,
  lapack,
  libhwy,
  cargo,
  rustc,
  fetchFromGitHub,
  rustPlatform,
  runCommand,
  lua5_4,
  llvmPackages,
  seams-core-src,
}:

let
  linkcellSrc = fetchFromGitHub {
    owner = "d-SEAMS";
    repo = "linkcell";
    rev = "v0.6.0";
    hash = "sha256-C1RPSOQHsBjfYxsw5Si6Q4+B+YGlQjNHitinndAv8XA=";
  };
  linkcellCargoVendor = rustPlatform.fetchCargoVendor {
    src = linkcellSrc;
    hash = "sha256-2QscNVUPmCrwO1cAHWnDZAtU8Hsr6Bl/WTO65WwDsC8=";
  };
  cargoHome = runCommand "yodastruct-cargo-home" { } ''
    mkdir -p "$out"
    cat > "$out/config.toml" <<EOF
    [source.vendored-source-registry-0]
    directory = "${linkcellCargoVendor}/source-registry-0"

    [source.crates-io]
    replace-with = "vendored-source-registry-0"
    EOF
  '';
in
stdenv.mkDerivation {
  pname = "dseams";
  version = "2.14.2";

  src = lib.fileset.toSource {
    root = ./..;
    fileset = lib.fileset.unions [
      ../meson.build
      ../src
      ../lua
      ../example_lua
      ../input
      ../templates
      ../lua_inputs
    ];
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    lua5_4
    cargo
    rustc
  ];

  buildInputs = [
    eigen
    blas
    lapack
    libhwy
    lua5_4
  ]
  ++ lib.optionals stdenv.cc.isClang [ llvmPackages.openmp ];

  mesonAutoFeatures = "disabled";

  preConfigure = ''
    export DSEAMS_SOURCE_DIR="$PWD"
    export CARGO_HOME=${cargoHome}
    export CARGO_NET_OFFLINE=true
  '';

  postPatch = ''
    mkdir -p subprojects
    cp -r ${seams-core-src} subprojects/seams-core
    chmod -R u+w subprojects/seams-core
    cp -R ${linkcellSrc} subprojects/linkcell
    chmod -R u+w subprojects/linkcell
    cp ${seams-core-src}/subprojects/linkcell.wrap subprojects/linkcell.wrap
  '';

  doCheck = true;

  postInstall = ''
    mkdir -p $out/share/lua/${lua5_4.luaversion} $out/lib/lua/${lua5_4.luaversion}
    ln -s $out/share/luadseams/lua/dseams.lua $out/share/lua/${lua5_4.luaversion}/dseams.lua
    ln -s $out/share/luadseams/lua/yoda.lua $out/share/lua/${lua5_4.luaversion}/yoda.lua
    if [ -e $out/lib/dseams_core.so ]; then
      ln -s $out/lib/dseams_core.so $out/lib/lua/${lua5_4.luaversion}/dseams_core.so
    fi
    mkdir -p $out/nix-support
    cat > $out/nix-support/setup-hook <<EOF
    addToSearchPath LUA_PATH "$out/share/luadseams/lua/?.lua"
    addToSearchPath LUA_CPATH "$out/lib/?.so"
    EOF
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    cd "$DSEAMS_SOURCE_DIR"
    DSEAMS_INSTALL_ROOT="$out" \
      LUA_PATH="$out/share/luadseams/lua/?.lua;;" \
      LUA_CPATH="$out/lib/?.so;;" \
      lua example_lua/library/installed.lua
  '';

  meta = {
    description = "d-SEAMS Lua and Fennel library (require(\"dseams\"))";
    homepage = "https://github.com/d-SEAMS/yodaStruct";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}

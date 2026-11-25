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
  symlinkJoin,
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
  libompPrefix = symlinkJoin {
    name = "yodastruct-libomp";
    paths = [
      (lib.getDev llvmPackages.openmp)
      (lib.getLib llvmPackages.openmp)
    ];
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
  # [[[cog
  # import dseams_version as v
  # cog.outl('  version = "%s";' % v.VERSION)
  # ]]]
  version = "2.14.2";
  # [[[end]]]

  src = lib.fileset.toSource {
    root = ./..;
    fileset = lib.fileset.unions [
      ../meson.build
      ../meson_options.txt
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
  '' + lib.optionalString stdenv.hostPlatform.isDarwin ''
    export LIBOMP_PREFIX=${libompPrefix}
  '';

  postPatch = ''
    mkdir -p subprojects
    cp -r ${seams-core-src} subprojects/seams-core
    chmod -R u+w subprojects/seams-core
    cp -R ${linkcellSrc} subprojects/linkcell
    chmod -R u+w subprojects/linkcell
    cp ${seams-core-src}/subprojects/linkcell.wrap subprojects/linkcell.wrap
    for patch in linkcell-conda-openmp.patch linkcell-macos-rpath.patch; do
      patch -d subprojects/linkcell -p1 < "subprojects/seams-core/subprojects/packagefiles/$patch"
    done
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
    description = "Lua and Fennel front end for d-SEAMS: LAMMPS, XYZ, optional .con (readcon-core) and PDB/GRO/DCD (chemfiles) reads; neighbour lists, rings, cages, CHILL and CHILL+, Steinhardt Ql, RDF, coordination numbers, density, hydrogen bonds, topology fingerprints, and site domains";
    homepage = "https://github.com/d-SEAMS/yodaStruct";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}

{
  lib,
  stdenv,
  meson,
  ninja,
  pkg-config,
  python3,
  eigen,
  blas,
  lapack,
  libhwy,
  lua5_4,
  luajit,
  llvmPackages,
  seams-core-src,
}:

stdenv.mkDerivation {
  pname = "dseams";
  version = "2.14.0";

  src = lib.fileset.toSource {
    root = ./..;
    fileset = lib.fileset.unions [
      ../meson.build
      ../meson.options
      ../src
      ../lua
      ../tests
      ../examples
      ../input
    ];
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    python3
    lua5_4
    luajit
  ];

  buildInputs = [
    eigen
    blas
    lapack
    libhwy
    lua5_4
    luajit
  ]
  ++ lib.optionals stdenv.cc.isClang [ llvmPackages.openmp ];

  # The engine's optional readers (readcon, chemfiles) and neighbour
  # backends stay off in the sandbox, so the meson Lua suite, which reads
  # .con and .xyz frames, runs in CI instead. installCheckPhase loads the
  # installed module on both interpreters.
  mesonAutoFeatures = "disabled";
  mesonFlags = [
    (lib.mesonEnable "with_lua" true)
    (lib.mesonBool "with_tests" false)
  ];

  postPatch = ''
    mkdir -p subprojects
    cp -r ${seams-core-src} subprojects/seams-core
    chmod -R u+w subprojects/seams-core
    rm -rf subprojects/seams-core/subprojects
    patchShebangs src/gen_ffi.py
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck
    export LD_LIBRARY_PATH="$out/lib" OMP_NUM_THREADS=1
    LUA_PATH="$out/share/lua/5.4/?.lua;;" LUA_CPATH="$out/lib/lua/5.4/?.so;;" \
      ${lua5_4}/bin/lua "$src/tests/test_rock.lua" "$src"
    LUA_PATH="$out/share/lua/5.1/?.lua;;" LUA_CPATH="$out/lib/lua/5.1/?.so;;" \
      ${luajit}/bin/luajit "$src/tests/test_rock.lua" "$src"
    runHook postInstallCheck
  '';

  meta = {
    description = "d-SEAMS Lua and Fennel library (require(\"dseams\"))";
    homepage = "https://github.com/d-SEAMS/yodaStruct";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}

{
  description = "d-SEAMS Lua and Fennel library (require(\"dseams\"))";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Source only: meson builds seams-core as a subproject. Same tag as
    # subprojects/seams-core.wrap.
    seams-core = {
      url = "github:d-SEAMS/seams-core/v2.14.0";
      flake = false;
    };
  };

  outputs =
    { self, nixpkgs, seams-core }:
    let
      inherit (nixpkgs) lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = lib.genAttrs systems;
      pkgsFor = system: nixpkgs.legacyPackages.${system};
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
          dseams = pkgs.callPackage ./nix/package.nix {
            seams-core-src = seams-core;
          };
        in
        {
          inherit dseams;
          default = dseams;
        }
      );

      checks = forAllSystems (system: {
        dseams = self.packages.${system}.default;
        default = self.checks.${system}.dseams;
      });

      devShells = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
          dseams = self.packages.${system}.default;
        in
        {
          default = pkgs.mkShell {
            name = "dseams-dev";
            inputsFrom = [ dseams ];
            packages = with pkgs; [
              lua5_4
              luajit
              gdb
            ];
            env = {
              LUA_PATH = "${dseams}/share/lua/5.4/?.lua;;";
              LUA_CPATH = "${dseams}/lib/lua/5.4/?.so;;";
              LD_LIBRARY_PATH = "${dseams}/lib";
            };
          };
        }
      );

      formatter = forAllSystems (system: (pkgsFor system).nixfmt);
    };
}

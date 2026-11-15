# The file is dseams_core.so because dseams.c exports luaopen_dseams_core.
# Each interpreter gets its own directory, in the build and in the install.
luajit_mod = shared_module(
  'dseams_core',
  files('../dseams.c'),
  name_prefix: '',
  name_suffix: 'so',
  dependencies: [luajit_dep],
  link_with: [seams_api_lib],
  c_args: seams_api_cargs,
  build_rpath: rpath,
  install: true,
  install_dir: get_option('libdir') / 'lua' / '5.1',
  install_rpath: get_option('prefix') / get_option('libdir'),
)
lua_mod_targets += luajit_mod
lua_runners += [find_program('luajit').full_path(), meson.current_build_dir()]

# The file is dseams_core.so because dseams.c exports luaopen_dseams_core.
# Each interpreter gets its own directory, in the build and in the install.
lua54_mod = shared_module(
  'dseams_core',
  files('../dseams.c'),
  name_prefix: '',
  name_suffix: 'so',
  dependencies: [lua54_dep],
  link_with: [seams_api_lib],
  c_args: lua54_cargs,
  build_rpath: rpath,
  install: true,
  install_dir: get_option('libdir') / 'lua' / '5.4',
  install_rpath: get_option('prefix') / get_option('libdir'),
)
lua_mod_targets += lua54_mod
lua54_prog = find_program('lua5.4', required: false)
if not lua54_prog.found()
  lua54_prog = find_program('lua', required: false)
endif
if lua54_prog.found()
  lua_runners += [lua54_prog.full_path(), meson.current_build_dir()]
endif

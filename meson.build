project(
  'dseams',
  ['c', 'cpp'],
  version: '2.14.0',
  license: 'MIT',
  default_options: ['warning_level=1', 'cpp_std=c++20'],
  meson_version: '>=1.3.0',
)

# require("dseams") for Lua 5.4 and LuaJIT over the d-SEAMS C API
# (seams.h). seams-core is the engine; subprojects/seams-core.wrap pins it.
# The engine hooks and the other language fronts stay off.
seams = subproject(
  'seams-core',
  default_options: [
    'default_library=shared',
    'with_tests=false',
    'with_python=false',
    'with_cli=false',
    'with_lua=disabled',
    'with_fortran=disabled',
    'with_lammps=disabled',
    'with_gromacs=disabled',
    'with_openmm=disabled',
    'with_plumed=disabled',
    'with_gpulite=disabled',
  ],
)
seams_api_lib = seams.get_variable('seams_api_lib')
yds_dep = seams.get_variable('yds_dep')

# seams.h and the generated seams_version.h. Meson does not hand a
# subproject's include_directories to its parent, so they travel as -I.
seams_src = meson.project_source_root() / 'subprojects' / 'seams-core'
seams_build = meson.project_build_root() / 'subprojects' / 'seams-core'
seams_h = seams_src / 'include' / 'seams.h'
seams_api_cargs = ['-I' + seams_src / 'include', '-I' + seams_build / 'src']
seams_libdir = seams_build / 'src'

subdir('src')

install_data(
  files('lua/dseams.lua', 'lua/yoda.lua', 'lua/dseams_fnl.fnl', 'lua/seams.fnl'),
  install_dir: get_option('datadir') / 'lua' / '5.4',
)
install_data(
  files('lua/dseams.lua', 'lua/yoda.lua', 'lua/dseams_fnl.fnl', 'lua/seams.fnl'),
  install_dir: get_option('datadir') / 'lua' / '5.1',
)

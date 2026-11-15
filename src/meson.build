# Lua 5.4 and LuaJIT modules over libseams. Fennel compiles to the same module.

lua_opt = get_option('with_lua')
if lua_opt.disabled()
  subdir_done()
endif

cc = meson.get_compiler('c')
lua54_dep = dependency('lua5.4', required: false)
if not lua54_dep.found()
  lua54_dep = dependency('lua-5.4', required: false)
endif
if not lua54_dep.found()
  # conda-forge and Homebrew name the 5.4 package lua.
  lua54_dep = dependency('lua', version: ['>=5.4', '<5.5'], required: false)
endif
if not lua54_dep.found()
  lua54_lib = cc.find_library('lua5.4', required: false, dirs: ['/usr/lib/x86_64-linux-gnu'])
  if lua54_lib.found() and cc.has_header('lua.h', args: ['-I/usr/include/lua5.4'])
    lua54_dep = declare_dependency(
      dependencies: [lua54_lib],
      compile_args: ['-I/usr/include/lua5.4'],
    )
  endif
endif
luajit_dep = dependency('luajit', required: false)
if not luajit_dep.found()
  luajit_probe = run_command('pkg-config', '--cflags', '--libs', 'luajit', check: false)
  if luajit_probe.returncode() == 0
    luajit_args = luajit_probe.stdout().split()
    luajit_compile = []
    luajit_link = []
    foreach flag : luajit_args
      if flag.startswith('-I') or flag.startswith('-D')
        luajit_compile += flag
      else
        luajit_link += flag
      endif
    endforeach
    luajit_dep = declare_dependency(
      compile_args: luajit_compile,
      link_args: luajit_link,
    )
  endif
endif
# Debian relocates prefix from the multiarch pkgconfig directory, so the
# stock Cflags point at a directory that does not hold lauxlib.h. Ask
# pkg-config for the prefix written in the file.
if luajit_dep.found() and not cc.has_header('lauxlib.h', dependencies: luajit_dep, required: false)
  luajit_probe = run_command('pkg-config', '--dont-define-prefix', '--cflags', '--libs', 'luajit', check: false)
  if luajit_probe.returncode() == 0
    luajit_args = luajit_probe.stdout().split()
    luajit_compile = []
    luajit_link = []
    foreach flag : luajit_args
      if flag.startswith('-I') or flag.startswith('-D')
        luajit_compile += flag
      else
        luajit_link += flag
      endif
    endforeach
    luajit_dep = declare_dependency(
      compile_args: luajit_compile,
      link_args: luajit_link,
    )
  endif
endif

if not lua54_dep.found() and not luajit_dep.found()
  if lua_opt.enabled()
    error('with_lua is enabled and neither Lua 5.4 nor LuaJIT was found')
  endif
  subdir_done()
endif

fs = import('fs')
fennel_lua = ''
fennel_candidates = [get_option('fennel_lua'), '/usr/local/share/fennel.lua', '/usr/share/lua/5.4/fennel.lua']
conda_prefix = run_command('sh', '-c', 'printf %s "$CONDA_PREFIX"', check: false)
if conda_prefix.returncode() == 0 and conda_prefix.stdout() != ''
  fennel_candidates += conda_prefix.stdout() / 'share/lua/5.4/fennel.lua'
endif
lua_prog = find_program('lua', required: false)
if lua_prog.found()
  fennel_candidates += fs.parent(fs.parent(lua_prog.full_path())) / 'share/lua/5.4/fennel.lua'
endif
foreach candidate : fennel_candidates
  if fennel_lua == '' and fs.exists(candidate)
    fennel_lua = candidate
  endif
endforeach
if fennel_lua == '' and get_option('with_tests')
  error('the Lua tests need the Fennel compiler: pass -Dfennel_lua=FILE (scripts/fetch_fennel.sh fetches one) or -Dwith_tests=false')
endif

lua54_cargs = seams_api_cargs
# Debian's lua5.4/luaconf.h includes a multiarch header that lives beside
# the compiler's system includes. A non-distro compiler does not search it.
# Other distributions have no dpkg-architecture and need no extra path.
dpkg_arch = find_program('dpkg-architecture', required: false)
deb_ok = false
if dpkg_arch.found()
  deb_arch = run_command(dpkg_arch, '-qDEB_HOST_MULTIARCH', check: false)
  deb_ok = deb_arch.returncode() == 0
endif
if deb_ok
  deb_inc = '/usr/include/' + deb_arch.stdout().strip()
  deb_header = deb_inc / 'lua5.4-deb-multiarch.h'
  # A private directory, so the multiarch -I does not hide the compiler's libc.
  deb_private = meson.current_build_dir() / 'lua54-multiarch'
  if fs.exists(deb_header)
    run_command('mkdir', '-p', deb_private, check: true)
    run_command('cp', deb_header, deb_private / 'lua5.4-deb-multiarch.h', check: true)
    lua54_cargs += '-I' + deb_private
  endif
endif
rpath = seams_libdir

ffi = custom_target(
  'dseams_ffi_lua',
  output: 'dseams_ffi.lua',
  command: [find_program('python3'), files('gen_ffi.py'), seams_h, '@OUTPUT@'],
  build_by_default: true,
)

lua_runners = []
lua_mod_targets = []
if lua54_dep.found()
  subdir('lua54')
endif
if luajit_dep.found()
  subdir('luajit')
endif

if get_option('with_tests') and lua_runners.length() > 0 and fennel_lua != ''
  oracle = executable(
    'lua_oracle',
    files('../tests/lua_oracle.cpp'),
    dependencies: [yds_dep],
    build_rpath: rpath,
  )
  lua_env = environment()
  lua_env.set('FENNEL_LUA', fennel_lua)
  lua_env.set('OMP_NUM_THREADS', '1')
  test(
    'lua_examples',
    find_program('python3'),
    args: [
      meson.project_source_root() / 'tests' / 'lua_examples.py',
      meson.project_source_root(),
      meson.current_build_dir(),
      oracle.full_path(),
      ffi.full_path(),
      seams_api_lib.full_path(),
    ] + lua_runners,
    env: lua_env,
    depends: [oracle, ffi, seams_api_lib] + lua_mod_targets,
    timeout: 600,
  )
endif

if get_option('with_tests') and lua_runners.length() > 0
  docs_env = environment()
  docs_env.set('OMP_NUM_THREADS', '1')
  docs_env.set('LD_LIBRARY_PATH', seams_libdir)
  test(
    'lua_docs_examples',
    find_program('python3'),
    args: [
      meson.project_source_root() / 'tests' / 'lua_docs_examples.py',
      meson.project_source_root(),
    ] + lua_runners,
    env: docs_env,
    depends: lua_mod_targets,
    timeout: 300,
  )

  # bindings spec, when busted is installed (luarocks install busted).
  busted = find_program('busted', required: false)
  if busted.found() and lua54_dep.found()
    busted_env = environment()
    busted_env.set('OMP_NUM_THREADS', '1')
    busted_env.set('LD_LIBRARY_PATH', seams_libdir)
    busted_env.set('LUA_PATH', meson.project_source_root() / 'lua' / '?.lua;;')
    busted_env.set('LUA_CPATH', meson.current_build_dir() / 'lua54' / '?.so;;')
    test(
      'lua_busted_spec',
      busted,
      args: [meson.project_source_root() / 'spec'],
      env: busted_env,
      workdir: meson.project_source_root(),
      depends: lua_mod_targets,
      timeout: 300,
    )
  endif
endif

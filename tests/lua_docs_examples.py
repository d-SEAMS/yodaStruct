#!/usr/bin/env python3
# Copyright (c) d-SEAMS developers
# SPDX-License-Identifier: MIT
"""Run the docs Lua examples on every interpreter the build made a module for.

argv: ROOT then interpreter, cpath-directory pairs.
"""

import os
import pathlib
import subprocess
import sys


def run(cmd, env, cwd):
    done = subprocess.run(cmd, cwd=cwd, env=env, text=True,
                          stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    if done.returncode != 0:
        raise SystemExit("$ {}\n{}".format(" ".join(cmd), done.stdout[-2000:]))
    return done.stdout


def main(argv):
    root = pathlib.Path(argv[1])
    pairs = argv[2:]
    if not pairs or len(pairs) % 2 != 0:
        raise SystemExit("lua modules are interpreter, cpath pairs")
    fixture = str(root / "input" / "traj" / "genice_sI.lammpstrj")
    for index in range(0, len(pairs), 2):
        lua, cpath = pairs[index], pairs[index + 1]
        env = os.environ.copy()
        env["LUA_PATH"] = str(root / "lua") + "/?.lua;;"
        env["LUA_CPATH"] = cpath + "/?.so;;"
        text = run([lua, str(root / "docs" / "examples" / "minimal_lua.lua"), fixture], env, root)
        if "lua clathrate 46" not in text:
            raise SystemExit("{} minimal_lua.lua printed\n{}".format(lua, text))
        text = run([lua, str(root / "docs" / "examples" / "lua_analyses.lua")], env, root)
        if "hexagonal 128" not in text:
            raise SystemExit("{} lua_analyses.lua printed\n{}".format(lua, text))
    print("lua docs examples ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))

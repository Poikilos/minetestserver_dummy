#!/usr/bin/env python
from __future__ import print_function # Only Python 2.x
import platform
import os
import sys

import subprocess

profile = None
if platform.system() == "Windows":
    profile = os.environ["USERPROFILE"]
else:
    profile = os.environ["HOME"]

# print("* using profile path '{}'".format(profile))
# TODO: Allow user to set these:
repos = os.path.join(profile, "git")
minetest = os.path.join(profile, "minetest")
games = os.path.join(minetest, "games")
game = os.path.join(games, "Bucket_Game")
mods_path = os.path.join(game, "mods")
builtin_path = os.path.join(minetest, "builtin")
paths = []  # This changes in main()

mod_paths = {}
modpack_paths = {}
max_depth = 2

_lua_enclosure_fmt = '--{} "{}"'


def get_mods(folder_path, suppress_bad=False, depth=0,
             append_to_paths=True):
    if append_to_paths:
        paths.append(folder_path)
    # print("Looking in '{}'...".format(folder_path))
    for sub_name in os.listdir(folder_path):
        sub_path = os.path.join(folder_path, sub_name)
        if os.path.isdir(sub_path) and not sub_name.startswith("."):
            try_init = os.path.join(sub_path, "init.lua")
            is_mod = os.path.isfile(try_init)
            try_modpack = os.path.join(sub_path, "modpack.txt")
            is_modpack = False
            if os.path.isfile(try_modpack):
                is_mod = False
                is_modpack = True
                modpack_paths[sub_name] = sub_path
                # print("  * added modpack: {}".format(sub_path))
            if is_mod:
                mod_paths[sub_name] = sub_path
                # print("    * added mod: {}".format(sub_path))
            else:
                if is_modpack:
                    if depth + 1 <= max_depth:
                        get_mods(sub_path, suppress_bad=suppress_bad, depth=depth+1)
                else:
                    if not suppress_bad:
                        print("    * '{}' is not a valid"
                              " mod.".format(sub_path))

loaded_mods = []
loaded_lines = []

def force_load_lua_line(line):
    loaded_lines.append(line)


# forced_mods = []

def force_load_lua_lines(lines, lua_path, mod_name):
    this_fmt = _lua_enclosure_fmt
    if mod_name is None:
        raise ValueError("You must provide mod names even for dummies.")
    loaded_mods.append(mod_name)
    loaded_lines.append("current_modname = {}".format(mod_name))
    loaded_lines.append("-- [minetest_dummy lua] The line after the"
                        " next is line 1 in force-loaded lines from"
                        " {}".format(mod_name))
    line = _lua_enclosure_fmt.format("START", lua_path)

    loaded_lines.append(line)
    loaded_lines.extend(lines)
    if mod_name is not None:
        loaded_lines.append(_lua_enclosure_fmt.format("END", lua_path))


def force_load_lua(lua_path, mod_name):
    force_load_lua_lines([line.rstrip('\n') for line in open(lua_path)],
                         lua_path, mod_name)

def load_mod(mod_path):
    name = os.path.split(mod_path)[-1]
    if name in loaded_mods:
        print("* [minetest_dummy python] {} is already_loaded, so"
              " '{}' will be skipped.".format(name, mod_path))
        return True
    loaded_mods.append(name)
    print("* {} is now marked as loaded.".format(name))
    depends_path = os.path.join(mod_path, "depends.txt")
    if os.path.isfile(depends_path):
        current_depends = [line.strip() for line in open(depends_path)]
        for line in current_depends:
            if len(line) > 0:
                optional = False
                sub_mod_name = line
                if line.endswith("?"):
                    optional = True
                    sub_mod_name = line[:-1]
                sub_mod_path = mod_paths.get(sub_mod_name)
                if sub_mod_path is not None:
                    if sub_mod_name not in loaded_mods:
                        load_mod(sub_mod_path)
                else:
                    raise RuntimeError(
                        "* ERROR: The mod {} is not in the paths"
                        " ({})".format(sub_mod_name, ", ".join(paths))
                    )

    lua_path = os.path.join(mod_path, "init.lua")
    current_lines = [line.rstrip('\n') for line in open(lua_path)]
    loaded_lines.append('current_modname = "{}"'.format(name))
    # TODO: set _last_run_mod at the time of every lua call??
    loaded_lines.append('_last_run_mod = "{}"'.format(name))
    loaded_lines.append("-- [minetest_dummy lua] The line after the next is"
                        " line 1 in {}'s init.lua".format(mod_path))
    loaded_lines.append(_lua_enclosure_fmt.format("START", lua_path))
    loaded_lines.extend(current_lines)
    loaded_lines.append(_lua_enclosure_fmt.format("END", lua_path))
    return True

def DEPECATED_execute_iterator(cmd):
    """This is an iterator! See
    <https://stackoverflow.com/questions/4417546/
    constantly-print-subprocess-output-while-process-is-running>
    AVOID this version, as it can produce `UnicodeDecodeError: 'utf-8' codec can't decode byte 0x93 in position 29: invalid start byte`
    in popen.stdout.readline.
    """
    popen = subprocess.Popen(cmd, stdout=subprocess.PIPE, universal_newlines=True)
    for stdout_line in iter(popen.stdout.readline, ""):
        yield stdout_line
    popen.stdout.close()
    return_code = popen.wait()
    if return_code:
        raise subprocess.CalledProcessError(return_code, cmd)

def execute(cmd):
    """See Rômulo Ceccon's May 11 '10 at 18:48 answer edited Jun 2 '19 at 16:02 on
    <https://stackoverflow.com/questions/2804543/read-subprocess-stdout-line-by-line>
    """
    proc = subprocess.Popen(cmd,stdout=subprocess.PIPE)
    lines = []
    while True:
        line = proc.stdout.readline()
        if not line:
            break
        try:
            print(line.decode().rstrip())
        except UnicodeDecodeError:
            print(line.rstrip())
    return lines


def test_translations(mod_path):

    # -- dofile doesn't preserve globals above in the called files. We
    # -- must append the lua like minetest does.
    # -- test-travelnet.py
    # -- current_modname = "intllib"
    # -- dofile("/home/owner/git/intllib/init.lua")
    # -- current_modname = "travelnet"
    # -- dofile("unused/intllib_substitute.lua") -- from Poikilos'
    # -- travelnet based on travelnet by Sokomine
    # -- dofile("/home/owner/git/minetest_dummy/unused/check-pot.lua")
    # /home/owner/git/travelnet/
    locale_path = os.path.join(mod_path, "locale")
    template_path = None
    languages = []
    language_paths = []
    folder_path = locale_path
    for sub_name in os.listdir(folder_path):
        sub_path = os.path.join(folder_path, sub_name)
        if os.path.isfile(sub_path):
            if not sub_name.startswith("."):
                if sub_name == "template.pot":
                    template_path = sub_path
                elif sub_name.endswith(".po"):
                    language_paths.append(sub_path)
                    languages.append(os.path.splitext(sub_name)[0])
                else:
                    print("* ERROR: unrecognized translation filename:"
                          " {}".format(sub_path))
    print("* test_translations detected: " + ", ".join(languages))
    load_mod(mod_path)

    # all_mods = loaded_mods + forced_mods
    loaded_lines.append('print("{}")'.format("* [minetest_dummy lua] Lua init completed for: {}".format(loaded_mods)))
    print(
        "* loaded {} line(s) from: {}".format(
            len(loaded_lines),
            ", ".join(loaded_mods)
        )
    )
    tmp_path = "tmp.lua"
    with open(tmp_path, 'w') as outs:
        for line in loaded_lines:
            outs.write(line + "\n")
    print("* Running '{}'...".format(tmp_path))
    # print("  Run it to complete the test.")
    try:
        for line in execute(["lua", tmp_path]):
            pass  # print(line)
    except subprocess.CalledProcessError as e:
        print("  * '{}' failed.".format(tmp_path))
    except Exception as e:
        raise e
    finally:
        pass
        # os.remove(tmp_path)
        # print("* removed '{}'".format(tmp_path))

args = sys.argv
def main():
    global repos
    global minetest
    global games
    global game
    global mods_path
    global builtin_path
    global paths

    # Your personal projects path FIRST
    print("* getting mods in repos '{}'...".format(repos))

    get_mods(repos, suppress_bad=True)  # Your personal repos path FIRST
    print("* minetest_dummy discovered {} mod(s) in or outside of"
          " {} modpack(s) so far...".format(len(mod_paths),
                                            len(modpack_paths)))

    settings = {}
    settings["use_version"] = "5"
    for arg_i in range(1, len(args)):  # skip 0 which is self
        arg = args[arg_i]
        if arg.startswith("--"):
            sign_i = arg.find("=")
            if sign_i > -1:
                name = arg[:sign_i]
                value = arg[sign_i+1:]
                settings[name] = value
    print("* [minetest_dummy python] using settings:")
    for k, v in settings.items():
        print('  {}: "{}"'.format(k, v))
    share = "/usr/share"
    # compiled minetest (in "local") should take priority:
    try_shares = ["/usr/local/share", "/usr/local/share/games", "/usr/share", "/usr/share/games", "C:\\games"]
    system_minetest = None
    for try_share in try_shares:
        try_minetest = os.path.join(try_share, "minetest")
        if os.path.isdir(try_minetest):
            system_minetest = try_minetest
            share = try_share
            # the local takes precedence
    good_share_flag_dir_name = "minetest"
    if settings["use_version"] == "4":
        minetest = os.path.join(share, "minetest")
        games = os.path.join(minetest, "games")
        game = os.path.join(games, "minetest_game")
        mods_path = os.path.join(game, "mods")
        builtin_path = os.path.join(minetest, "builtin")
    elif settings["use_version"] == "5":
        minetest = os.path.join(share, "minetest")
        minetest_profile = os.path.join(profile, ".minetest")
        games = os.path.join(minetest_profile, "games")
        game = os.path.join(games, "ENLIVEN")
        mods_path = os.path.join(game, "mods")
        builtin_path = os.path.join(minetest, "builtin")
    elif settings["use_version"] == "6":
        builtin_path = os.path.join(minetest, "builtin")
    else:
        raise ValueError("* minetest version {} is not implemented ".format(settings["use_version"]))
    if not os.path.isdir(minetest):
        if os.path.isdir(system_minetest):
            print("* missing '{}'...reverting to '{}'".format(minetest, system_minetest))
            minetest = system_minetest
            minetest_profile = os.path.join(profile, ".minetest")
            games = os.path.join(minetest_profile, "games")
            game = os.path.join(games, "ENLIVEN")
            mods_path = os.path.join(game, "mods")
            builtin_path = os.path.join(minetest, "builtin")
        else:
            raise RuntimeError("'{}' is missing".format(minetest))
    else:
        print("* using minetest directory '{}'".format(minetest))
        if system_minetest is not None:
            print("  (the system's minetest is '{}')".format(system_minetest))
        else:
            print("  (there is no systemwide-installed version)")
    if not os.path.isdir(mods_path):
        raise RuntimeError("mods_path '{}' does not exist".format(mods_path))
    loaded_lines.append('DIR_DELIM = "' + os.path.sep + '"')
    # INIT must be game, mainmenu, async, or client:
    loaded_lines.append('INIT = "game"')
    loaded_lines.append("print(\"  * [minetest_dummy lua] DIR_DELIM is '\"..DIR_DELIM..\"'\")")
    loaded_lines.append('builtin_path = "{}{}"'.format(builtin_path,
                                                       os.path.sep))
    loaded_lines.append('local _settings_values = {}')  # TODO: fill in this table
    # TODO: load defaults then _settings_values
    loaded_lines.append('_settings_values.language = "{}"'.format("ru"))  # TODO: allow user to set language
    loaded_lines.append('local _mapgen_settings_values = {}')
    # Minimum _mapgen_settings_values:
    # - chunksize must be an int.
    # TODO: load defaults then _mapgen_settings_values
    loaded_lines.append('_mapgen_settings_values.{} = {}'.format("chunksize", 16))

    loaded_lines.append("mod_parents = {}")
    # get_mods must be done right away so we have all parent locations
    # (mod_parents) of all mods. It doesn't cause a problem
    # with Lua line order, as it does not load any Lua lines.
    print("* getting mods in mods_path '{}'...".format(mods_path))
    get_mods(mods_path)

    loaded_lines.append('current_modname = "{}"'.format(""))
    # TODO: set _last_run_mod at the time of every lua call??
    loaded_lines.append('_last_run_mod = "{}"'.format(""))
    world_path = os.path.join(".", "tmp_world")  # TODO: allow real one?
    if not os.path.isdir(world_path):
        os.makedirs(world_path)
        print("* created temp world '{}'".format(world_path))
    else:
        print("* using world '{}'".format(world_path))
    loaded_lines.append('wpath = "{}"'.format(world_path))
    # TODO: populate Lua table named _mapgen_settings_values here
    # TODO: populate Lua table named _settings_values here
    # NOTE: modpacks must take priority, otherwise get_mod_path in dummy core will find <game>/mods/mesecons before <game>/mods/mesecons/mesecons!
    for name, path in modpack_paths.items():
        loaded_lines.append('mod_parents[#mod_parents+1] = "{}"'.format(path))
    for path in paths:
        loaded_lines.append('mod_parents[#mod_parents+1] = "{}"'.format(path))
    minetest_dummy = os.path.dirname(os.path.realpath(__file__))

    force_load_lua(os.path.join(minetest_dummy, "lua.lua"), "dummy_lua")
    force_load_lua(os.path.join(minetest_dummy, "lua_api.lua"), "dummy_lua_api")
    force_load_lua(os.path.join(builtin_path, "init.lua"), "builtin")
    # Override parts of core so things run in a dummy environment:
    force_load_lua(os.path.join(minetest_dummy, "core.lua"), "dummy_core")
    # Override parts of builtin so things run in a dummy environment:
    force_load_lua(os.path.join(minetest_dummy, "builtin.lua"), "dummy_builtin")


    print("* minetest_dummy discovered {} mod(s) in or outside of"
          " {} modpack(s).".format(len(mod_paths),
                                   len(modpack_paths)))
    # for name, path in modpack_paths.items():
    #     print("  - '{}'".format(path))
    # print("* mods:")
    # for name, path in mod_paths.items():
    #     print("  - '{}'".format(path))
    # NOTE: get_mods builds the paths list before this.

    # TODO: Check for sys.argv, and do something else below based on
    # that.

    test_translations("/home/owner/git/travelnet")



if __name__ == "__main__":
    main()


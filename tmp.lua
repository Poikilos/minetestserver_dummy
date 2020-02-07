DIR_DELIM = "/"
INIT = "game"
print("  * [minetest_dummy] DIR_DELIM is '"..DIR_DELIM.."'")
builtin_path = "/usr/local/share/minetest/builtin/"
local settings_values = {}
settings_values.language = "ru"
local mapgen_settings_values = {}
mod_parents = {}
current_modname = ""
_last_run_mod = ""
wpath = "./tmp_world"
mod_parents[#mod_parents+1] = "/home/owner/git"
mod_parents[#mod_parents+1] = "/home/owner/git/kc_modpack"
mod_parents[#mod_parents+1] = "/home/owner/git/mobs_sky-poikilos-2018-incorrect-license-mitigation"
mod_parents[#mod_parents+1] = "/home/owner/git/mobs_sky"
mod_parents[#mod_parents+1] = "/home/owner/.minetest/games/ENLIVEN/mods"
mod_parents[#mod_parents+1] = "/home/owner/.minetest/games/ENLIVEN/mods/worldedit"
mod_parents[#mod_parents+1] = "/home/owner/.minetest/games/ENLIVEN/mods/mobs_sky"
mod_parents[#mod_parents+1] = "/home/owner/.minetest/games/ENLIVEN/mods/spawners"
mod_parents[#mod_parents+1] = "/home/owner/.minetest/games/ENLIVEN/mods/plantlife_modpack"
mod_parents[#mod_parents+1] = "/home/owner/.minetest/games/ENLIVEN/mods/mesecons"
mod_parents[#mod_parents+1] = "/home/owner/.minetest/games/ENLIVEN/mods/3d_armor"
mod_parents[#mod_parents+1] = "/home/owner/.minetest/games/ENLIVEN/mods/homedecor_modpack"
mod_parents[#mod_parents+1] = "/home/owner/.minetest/games/ENLIVEN/mods/trmp_minetest_game"
mod_parents[#mod_parents+1] = "/home/owner/.minetest/games/ENLIVEN/mods/technic"
mod_parents[#mod_parents+1] = "/home/owner/git/kc_modpack"
mod_parents[#mod_parents+1] = "/home/owner/git/mobs_sky-poikilos-2018-incorrect-license-mitigation"
mod_parents[#mod_parents+1] = "/home/owner/.minetest/games/ENLIVEN/mods/mobs_sky"
mod_parents[#mod_parents+1] = "/home/owner/.minetest/games/ENLIVEN/mods/worldedit"
mod_parents[#mod_parents+1] = "/home/owner/.minetest/games/ENLIVEN/mods/spawners"
mod_parents[#mod_parents+1] = "/home/owner/.minetest/games/ENLIVEN/mods/plantlife_modpack"
mod_parents[#mod_parents+1] = "/home/owner/.minetest/games/ENLIVEN/mods/mesecons"
mod_parents[#mod_parents+1] = "/home/owner/.minetest/games/ENLIVEN/mods/3d_armor"
mod_parents[#mod_parents+1] = "/home/owner/.minetest/games/ENLIVEN/mods/homedecor_modpack"
mod_parents[#mod_parents+1] = "/home/owner/.minetest/games/ENLIVEN/mods/trmp_minetest_game"
mod_parents[#mod_parents+1] = "/home/owner/.minetest/games/ENLIVEN/mods/technic"
--START minetest_dummy/extras.lua (overrides standard Lua behavior)
--- exists and isdir are from https://stackoverflow.com/a/40195356
--- (Hisham H M's answer on https://stackoverflow.com/questions/1340230/check-if-directory-exists-in-lua)
--- Check if a file or directory exists in this path
function exists(file)
   local ok, err, code = os.rename(file, file)
   if not ok then
      if code == 13 then
         -- Permission denied, but it exists
         return true
      end
   end
   return ok, err
end

--- Check if a directory exists in this path
function isdir(path)
   -- "/" works on both Unix and Windows
   return exists(path.."/")
end

print("* Initializing minetest_dummy is complete.")


-- table.* are from http://lua-users.org/wiki/TableUtils

function table.tostring( tbl )
  local result, done = {}, {}
  for k, v in ipairs( tbl ) do
    table.insert( result, table.val_to_str( v ) )
    done[ k ] = true
  end
  for k, v in pairs( tbl ) do
    if not done[ k ] then
      table.insert( result,
        table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
    end
  end
  return "{" .. table.concat( result, "," ) .. "}"
end

function table.val_to_str ( v )
  if "string" == type( v ) then
    v = string.gsub( v, "\n", "\\n" )
    if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
      return "'" .. v .. "'"
    end
    return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
  else
    return "table" == type( v ) and table.tostring( v ) or
      tostring( v )
  end
end

function table.key_to_str ( k )
  if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
    return k
  else
    return "[" .. table.val_to_str( k ) .. "]"
  end
end

--[[
From http://lua-users.org/wiki/SortedIteration

Ordered table iterator, allow to iterate on the natural order of the keys of a
table.

Example:
]]

unordered_pairs = pairs  -- added by poikilos to prevent `pairs = orderedPairs` from causing infinite recursion
function __genOrderedIndex( t )
    local orderedIndex = {}
    for key in unordered_pairs(t) do
        table.insert( orderedIndex, key )
    end
    table.sort( orderedIndex )
    return orderedIndex
end

function orderedNext(t, state)
    -- Equivalent of the next function, but returns the keys in the alphabetic
    -- order. We use a temporary ordered key table that is stored in the
    -- table being iterated.

    local key = nil
    --print("orderedNext: state = "..tostring(state) )
    if state == nil then
        -- the first time, generate the index
        t.__orderedIndex = __genOrderedIndex( t )
        key = t.__orderedIndex[1]
    else
        -- fetch the next value
        -- Poikilos replaced table.getn(t.__orderedIndex) with `#t.__orderedIndex` (see https://stackoverflow.com/questions/47846884/lua-error-attempt-to-call-a-nil-value-field-getn)
        for i = 1,#t.__orderedIndex do
            if t.__orderedIndex[i] == state then
                key = t.__orderedIndex[i+1]
            end
        end
    end

    if key then
        return key, t[key]
    end

    -- no more value to return, cleanup
    t.__orderedIndex = nil
    return
end

function orderedPairs(t)
    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return orderedNext, t, nil
end


function _G.assert_(v)
   -- If renamed to assert for debugging purposes, this function overrides the existing Lua assert function to prevent minetest_dummy from crashing because it can't do things.
   -- "Lua: Basic Functions: assert. Issues an error when the value of its argument v is false (i.e., nil or false); otherwise, returns all its arguments."
   -- according to https://pgl.yoyo.org/luai/i/assert
   print("* [minetest_dummy] WARNING: an assertion failed. This is probably because setfenv is fake in minetest_dummy. "..debug.traceback())
   return v
end
-- _G.assert = assert

pairs = orderedPairs  -- This is necessary to prevent a failed assertion in minetest 5 where it tests core.privs_to_string at the end of builtin/common/misc_helpers.lua


--END minetest_dummy/extras.lua (overrides standard Lua behavior)


--START minetest_dummy/lua_api.lua (provides code that would otherwise be in minetest C code)

dummy_core = {}

function core_log(str)
	print(str)
end

dummy_core.log = core_log

function core_print(str)
	print(str)
end

this_env = "."

--region Do something closer to what minetest does here.
-- TODO: finish this
function setfenv(f, env)
	print("  * [minetest_dummy] is pretending to set env function '"..string.dump(f).."' for table '"..table.tostring(env).."'") -- table.tostring is from minetest_dummy/extras.lua
	this_env = this_env
end
function _G.dummy_core.clear_registered_biomes()
	print("  * [minetest_dummy] is pretending to clear_registered_biomes")
end
function _G.dummy_core.clear_registered_ores()
	print("  * [minetest_dummy] is pretending to clear_registered_ores")
end
function _G.dummy_core.clear_registered_decorations()
	print("  * [minetest_dummy] is pretending to clear_registered_decorations")
end
local _registered_biomes = {}
_registered_biomes["any"] = {}
function _G.dummy_core.register_biome(def)
	-- print("  * [minetest_dummy] is pretending to register biome: "..table.tostring(def))  -- table.tostring is from minetest_dummy/extras.lua
	-- _registered_biomes[#_registered_biomes+1] = def
	_registered_biomes[def.name] = def
end
function _G.dummy_core.unregister_biome(def)
	print("  * [minetest_dummy] is pretending to unregister biome "..table.tostring(def))
	_registered_biomes[def.name] = nil
end
-- local _registered_ores = {}

local function add_something_to_biome(name, biome, whats, def)
	local ret = true
	if _registered_biomes[biome] == nil then
		print("	 * ERROR: the biome '"..biome.."' is not registered yet during add_something_to_biome (def.ore='"..def.ore.."')")
	else
		if _registered_biomes[biome][whats] == nil then
			_registered_biomes[biome][whats] = {}
		end
		_registered_biomes[biome][whats][name] = def
	end
	return ret
end

function _G.dummy_core.register_ore(def)
	-- takes ore def such as {biomes={"cold_desert"},clust_scarcity=1,noise_params={octaves=1,offset=28,scale=16,seed=90122,spread={x=128,y=128,z=128}},ore="default:silver_sandstone",ore_type="stratum",stratum_thickness=4,wherein={"default:stone"},y_max=46,y_min=10}
	-- print("  * [minetest_dummy] is pretending to register ore: "..table.tostring(def))  -- table.tostring is from minetest_dummy/extras.lua
	if def.biomes ~= nil then
		for i = 1, #def.biomes do
			biome = def.biomes[i]
			print("	 * adding an ore '"..def.ore.."' to biome '"..biome.."'")
			add_something_to_biome(def.ore, biome, "ores", def)
		end
	 else
		biome = "any"
			print("	 * adding an ore '"..def.ore.."' for any biome")
		add_something_to_biome(def.ore, biome, "ores", def)
	 end
	-- _registered_ores[def.name] = def
end

local _registered_decorations = {}
function _G.dummy_core.register_decoration(def)
	-- TODO: make function that replaces both this and register_ore which both this and that call.
	-- takes decoration def
	print("  * [minetest_dummy] is pretending to register decoration: "..table.tostring(def))  -- table.tostring is from minetest_dummy/extras.lua
	local name = def.decoration
	if name == nil then
		name = def.name
		print("    * [minetest_dummy] WARNING: using def.decoration instead of def.name for "..name)
	end
	if def.biomes ~= nil then
		for i = 1, #def.biomes do
			biome = def.biomes[i]
			print("	 * adding a decoration '"..name.."' to biome '"..biome.."'")
			add_something_to_biome(name, biome, "decorations", def)
		end
	 else
		biome = "any"
			print("	 * adding a decoration '"..name.."' for any biome")
		add_something_to_biome(name, biome, "decorations", def)
	 end
	-- _registered_decorations[def.name] = def
end


--endregion


callbacks = {"on_leaveplayer", "globalstep", "on_joinplayer", "abm", "leafdecay", "on_player_receive_fields"}
for i = 1, #callbacks do
	rawset(_G.dummy_core, "register_" .. callbacks[i], function(callback)
			if not rawget(_G, callbacks[i].."_callbacks") then
				rawset(_G, callbacks[i].."_callbacks", {})
			end
			rawset(_G, callbacks[i].."_callbacks[#"..callbacks[i].."_callbacks+1]", callback)
		end
	)
	-- NOTE: minetest_dummy/core.lua sets:
	-- rawset(_G.minetest, "register_" .. callbacks[i], rawget(core, "register_" .. callbacks[i]))
end

_aliases = {}
function dummy_core.register_alias_raw(name, convert_to)
	_aliases[name] = convert_to
end
_G.register_alias_raw = dummy_core.register_alias_raw

function dummy_core.get_builtin_path(str)
	return builtin_path  -- minetest_dummy's python code generates this!
end
function dummy_core.get_last_run_mod(str)
	return _last_run_mod  -- minetest_dummy's python code generates this!
end
function dummy_core.get_worldpath(str)
	return wpath  -- minetest_dummy's python code generates this!
	-- NOTE: wpath is part of the API, since used directly by:
	--	/usr/local/share/minetest/builtin/game/forceloading.lua
end
function dummy_core.get_modpath(str)
	-- minetest_dummy's python code generates mod_parents!
	local try_path = nil
	for i = 1, #mod_parents do
		local try_path = mod_parents[i] .. "/" .. str
		print("* trying to find " .. str .. " in '" .. mod_parents[i] .. "'")
		if str and isdir(try_path) then
			return try_path
		end
	end
	if try_path then
		print("- [minetest_dummy] WARNING: " .. try_path .. " does not exist.")
	else
		error("- [minetest_dummy] ERROR: trying to get path for "..str.." resulted in a nil path (#mod_parents="..#mod_parents..")!")
	end
	return nil
end

function dummy_core.get_mapgen_setting(str)
	return mapgen_settings_values[str]
end


function dummy_core.setting_get(str)
	return settings_values[str]
end
function dummy_core.setting_getbool(str)
	return settings_values[str]
end
function dummy_core.setting_set(str, v)
	settings_values[str] = v
end

dummy_core.settings = {}
dummy_core.settings.get = dummy_core.setting_get
dummy_core.settings.get_bool = dummy_core.setting_getbool
dummy_core.settings.set = dummy_core.setting_set

function dummy_core.register_node(name, node)
	nodes[name] = node
end

-- default says:
--function default.register_leafdecay(def)
	--assert(def.leaves)
	--assert(def.trunks)
	--assert(def.radius)
	--for _, v in pairs(def.trunks) do
		--minetest.override_item(v, {
			--after_destruct = function(pos, oldnode)
				--leafdecay_after_destruct(pos, oldnode, def)
			--end,
		--})
	--end
	--for _, v in pairs(def.leaves) do
		--minetest.override_item(v, {
			--on_timer = function(pos)
				--leafdecay_on_timer(pos, def)
			--end,
		--})
	--end
--end
function dummy_core.override_item(name, def)
	for key,value in pairs(def) do
		-- TODO: See if this mimics minetest correctly.
		print("* minetest_dummy is faking core.override: "..key)
		nodes[name][key] = value
	end
end


local crafts = {}

function dummy_core.register_craft(def)
	-- provide def such as:
	-- {
	-- 	output = name .. " 4",
	-- 	recipe = {
	-- 		{ def.material, 'group:stick', def.material },
	-- 		{ def.material, 'group:stick', def.material },
	-- 	}
	-- }
	crafts[#crafts+1] = def
end
local items = {}
function dummy_core.register_item_raw(def)
	-- This is called by dummy_core.register_item
	--	in /usr/local/share/minetest/builtin/game/register.lua
	-- provide def such as:
	-- {
	-- 	output = name .. " 4",
	-- 	recipe = {
	-- 		{ def.material, 'group:stick', def.material },
	-- 		{ def.material, 'group:stick', def.material },
	-- 	}
	-- }
	items[#items+1] = def
end
dummy_core.register_item = dummy_core.register_item_raw


local current_modname = ""

function dummy_core.get_current_modname()
	return current_modname
end

-- See http://lua-users.org/wiki/SplitJoin
-- iterate space-delimited: "for i in string.gmatch(example, "%S+") do"
function dummy_core.string_to_privs(privs)
	ret = {}
	-- regex notes:
	-- - `+` means preceding must occur 1 or more times, mandatory
	for s in string.gmatch(privs, ",+") do
		ret[s] = true
		print("* [minetest_dummy] got priv '"..s.."'")
	end
	return ret
end


--function dummy_core.privs_to_string(privs, delim)
	--delim = delim or ","
	---- called in builtin/common/misc_helpers.lua:761 like:
	----assert(core.string_to_privs("a,b").b == true)
	----assert(core.privs_to_string({a=true,b=true}) == "a,b")
	----The assertion above FAILS if privs_to_string changes the order, which it usually would.
	--ret = nil
	--for key,value in pairs(privs) do
		--if value then
			--if ret then
				--ret = ret + delim + key
			--else
				--ret = key
			--end
		--end
	--end
	--print("* [minetest_dummy] created privs string '"..ret.."'")
	--return ret
--end

function dummy_core.register_lbm(str)
	 -- Add to dummy_core.registered_lbms
	 -- formerly:
	 -- check_modname_prefix(spec.name)
	 -- assert(type(spec.action) == "function", "Required field 'action' of type function")
	 -- dummy_core.registered_lbms[#dummy_core.registered_lbms + 1] = spec
	 -- spec.mod_origin = dummy_core.get_current_modname() or "??"
	 print("* WARNING: register_lbm is not yet implemented in minetest_dummy")
end
-- dofile("/home/owner/git/intllib/init.lua")
--leaveplayer_callbacks = {}
--function minetest.register_on_leaveplayer(callback)
--	leaveplayer_callbacks[#leaveplayer_callbacks+1] = callback
--end
-- _G.register_on_leaveplayer = register_on_leaveplayer
-- rawset(_G, "register_on_leaveplayer", register_on_leaveplayer)

local dummy_player = {}
dummy_player.health = 0

local nodes = {}
function dummy_core.item_eat(value)
	dummy_player.health = dummy_player.health + value
end


--END minetest_dummy/lua_api.lua (provides code that would otherwise be in minetest C code)

core = dummy_core
--
-- This file contains built-in stuff in Minetest implemented in Lua.
--
-- It is always loaded and executed after registration of the C API,
-- before loading and running any mods.
--

-- Initialize some very basic things
function core.debug(...) core.log(table.concat({...}, "\t")) end
if core.print then
	local core_print = core.print
	-- Override native print and use
	-- terminal if that's turned on
	function print(...)
		local n, t = select("#", ...), {...}
		for i = 1, n do
			t[i] = tostring(t[i])
		end
		core_print(table.concat(t, "\t"))
	end
	core.print = nil -- don't pollute our namespace
end
math.randomseed(os.time())
minetest = core

-- Load other files
local scriptdir = core.get_builtin_path()
local gamepath = scriptdir .. "game" .. DIR_DELIM
local clientpath = scriptdir .. "client" .. DIR_DELIM
local commonpath = scriptdir .. "common" .. DIR_DELIM
local asyncpath = scriptdir .. "async" .. DIR_DELIM

dofile(commonpath .. "strict.lua")
dofile(commonpath .. "serialize.lua")
dofile(commonpath .. "misc_helpers.lua")

if INIT == "game" then
	dofile(gamepath .. "init.lua")
elseif INIT == "mainmenu" then
	local mm_script = core.settings:get("main_menu_script")
	if mm_script and mm_script ~= "" then
		dofile(mm_script)
	else
		dofile(core.get_mainmenu_path() .. DIR_DELIM .. "init.lua")
	end
elseif INIT == "async" then
	dofile(asyncpath .. "init.lua")
elseif INIT == "client" then
	dofile(clientpath .. "init.lua")
else
	error(("Unrecognized builtin initialization type %s!"):format(tostring(INIT)))
end
--START minetest_dummy/core.lua (overrides core behavior)
-- do NOT use the file this way: dofile("/home/owner/git/minetest_dummy/init.lua")
-- infinite loop: intllib = dofile("/home/owner/git/intllib/init.lua")
-- local extras = dofile("/home/owner/git/minetest_dummy/extras.lua") -- loaded by minetest_dummy via python instead, since must load before builtin

--minetest = {
--}
--minetest.register_alias_raw = core.register_alias_raw
--minetest.get_modpath = core.get_modpath
--minetest.get_mapgen_setting = core.get_mapgen_setting

--minetest.register_lbm = core.register_lbm
--minetest.setting_get = core.setting_get
--minetest.setting_getbool = core.setting_getbool
--minetest.setting_set = core.setting_set
--minetest.settings = core.settings
--for i = 1, #callbacks do
	--rawset(_G.minetest, "register_" .. callbacks[i], rawget(core, "register_" .. callbacks[i]))
	---- print("added callback '".."minetest.register_" .. callbacks[i])
--end

--minetest.register_node = core.register_node
--minetest.override_item = core.override_item
--minetest.register_craft = core.register_craft
core = dummy_core
minetest = core
-- dofile doesn't preserve globals above in the called files. We must append the lua like minetest does (from mods indicated in depends.txt files)
-- current_modname = "intllib"
-- dofile("/home/owner/git/intllib/init.lua")
-- current_modname = "travelnet"
-- dofile("unused/intllib_substitute.lua") -- from Poikilos' travelnet based on travelnet by Sokomine
-- dofile("/home/owner/git/minetest_dummy/unused/check-pot.lua")
--END minetest_dummy/core.lua (overrides core behavior)
-- TODO: move things from core to here if they are part of builtin but not part of core
function dummy_core.privs_to_string(privs)
	-- called in builtin/common/misc_helpers.lua:761 like:
	--assert(core.string_to_privs("a,b").b == true)
	--assert(core.privs_to_string({a=true,b=true}) == "a,b")
	--The assertion above FAILS if the order changes, which it usually would.
	ret = nil
	for key,value in pairs(privs) do
		if value then
			if ret then
				ret = ret + "," + key
			else
				ret = key
			end
		end
	end
	print("* [minetest_dummy] created privs string '"..ret.."'")
	return ret
end
current_modname = "player_api"
_last_run_mod = "player_api"
-- [minetest_dummy] The next line is line 1 in /home/owner/.minetest/games/ENLIVEN/mods/player_api's init.lua
dofile(minetest.get_modpath("player_api") .. "/api.lua")

-- Default player appearance
player_api.register_model("character.b3d", {
	animation_speed = 30,
	textures = {"character.png", },
	animations = {
		-- Standard animations.
		stand     = {x = 0,   y = 79},
		lay       = {x = 162, y = 166},
		walk      = {x = 168, y = 187},
		mine      = {x = 189, y = 198},
		walk_mine = {x = 200, y = 219},
		sit       = {x = 81,  y = 160},
	},
	collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3},
	stepheight = 0.6,
	eye_height = 1.47,
})

-- Update appearance when the player joins
minetest.register_on_joinplayer(function(player)
	player_api.player_attached[player:get_player_name()] = false
	player_api.set_model(player, "character.b3d")
	player:set_local_animation(
		{x = 0,   y = 79},
		{x = 168, y = 187},
		{x = 189, y = 198},
		{x = 200, y = 219},
		30
	)
	player:hud_set_hotbar_image("gui_hotbar.png")
	player:hud_set_hotbar_selected_image("gui_hotbar_selected.png")
end)
current_modname = "default"
_last_run_mod = "default"
-- [minetest_dummy] The next line is line 1 in /home/owner/.minetest/games/ENLIVEN/mods/default's init.lua
-- Minetest 0.4 mod: default
-- See README.txt for licensing and other information.

-- The API documentation in here was moved into game_api.txt

-- Definitions made by this mod that other mods can use too
default = {}

default.LIGHT_MAX = 14

-- GUI related stuff
minetest.register_on_joinplayer(function(player)
	player:set_formspec_prepend([[
			bgcolor[#080808BB;true]
			background[5,5;1,1;gui_formbg.png;true]
			background[5,5;1,1;gui_formbg.png;true;10]
			listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF] ]])
end)

function default.get_hotbar_bg(x,y)
	local out = ""
	for i=0,7,1 do
		out = out .."image["..x+i..","..y..";1,1;gui_hb_bg.png]"
	end
	return out
end

default.gui_survival_form = "size[8,8.5]"..
			"list[current_player;main;0,4.25;8,1;]"..
			"list[current_player;main;0,5.5;8,3;8]"..
			"list[current_player;craft;1.75,0.5;3,3;]"..
			"list[current_player;craftpreview;5.75,1.5;1,1;]"..
			"image[4.75,1.5;1,1;gui_furnace_arrow_bg.png^[transformR270]"..
			"listring[current_player;main]"..
			"listring[current_player;craft]"..
			default.get_hotbar_bg(0,4.25)

-- Load files
local default_path = minetest.get_modpath("default")

dofile(default_path.."/functions.lua")
dofile(default_path.."/trees.lua")
dofile(default_path.."/nodes.lua")
dofile(default_path.."/chests.lua")
dofile(default_path.."/furnace.lua")
dofile(default_path.."/torch.lua")
dofile(default_path.."/tools.lua")
dofile(default_path.."/item_entity.lua")
dofile(default_path.."/craftitems.lua")
dofile(default_path.."/crafting.lua")
dofile(default_path.."/mapgen.lua")
dofile(default_path.."/aliases.lua")
dofile(default_path.."/legacy.lua")
current_modname = "mesecons"
_last_run_mod = "mesecons"
-- [minetest_dummy] The next line is line 1 in /home/owner/.minetest/games/ENLIVEN/mods/mesecons/mesecons's init.lua
-- |\    /| ____ ____  ____ _____   ____         _____
-- | \  / | |    |     |    |      |    | |\   | |
-- |  \/  | |___ ____  |___ |      |    | | \  | |____
-- |      | |        | |    |      |    | |  \ |     |
-- |      | |___ ____| |___ |____  |____| |   \| ____|
-- by Jeija, Uberi (Temperest), sfan5, VanessaE, Hawk777 and contributors
--
--
--
-- This mod adds mesecons[=minecraft redstone] and different receptors/effectors to minetest.
-- See the documentation on the forum for additional information, especially about crafting
--
--
-- For basic development resources, see http://mesecons.net/developers.html
--
--
--
--Quick draft for the mesecons array in the node's definition
--mesecons =
--{
--	receptor =
--	{
--		state = mesecon.state.on/off
--		rules = rules/get_rules
--	},
--	effector =
--	{
--		action_on = function
--		action_off = function
--		action_change = function
--		rules = rules/get_rules
--	},
--	conductor =
--	{
--		state = mesecon.state.on/off
--		offstate = opposite state (for state = on only)
--		onstate = opposite state (for state = off only)
--		rules = rules/get_rules
--	}
--}

-- PUBLIC VARIABLES
mesecon={} -- contains all functions and all global variables
mesecon.queue={} -- contains the ActionQueue
mesecon.queue.funcs={} -- contains all ActionQueue functions

-- Settings
dofile(minetest.get_modpath("mesecons").."/settings.lua")

-- Utilities like comparing positions,
-- adding positions and rules,
-- mostly things that make the source look cleaner
dofile(minetest.get_modpath("mesecons").."/util.lua");

-- Presets (eg default rules)
dofile(minetest.get_modpath("mesecons").."/presets.lua");

-- The ActionQueue
-- Saves all the actions that have to be execute in the future
dofile(minetest.get_modpath("mesecons").."/actionqueue.lua");

-- Internal stuff
-- This is the most important file
-- it handles signal transmission and basically everything else
-- It is also responsible for managing the nodedef things,
-- like calling action_on/off/change
dofile(minetest.get_modpath("mesecons").."/internal.lua");

-- API
-- these are the only functions you need to remember

mesecon.queue:add_function("receptor_on", function (pos, rules)
	mesecon.vm_begin()

	rules = rules or mesecon.rules.default

	-- Call turnon on all linking positions
	for _, rule in ipairs(mesecon.flattenrules(rules)) do
		local np = vector.add(pos, rule)
		local rulenames = mesecon.rules_link_rule_all(pos, rule)
		for _, rulename in ipairs(rulenames) do
			mesecon.turnon(np, rulename)
		end
	end

	mesecon.vm_commit()
end)

function mesecon.receptor_on(pos, rules)
	mesecon.queue:add_action(pos, "receptor_on", {rules}, nil, rules)
end

mesecon.queue:add_function("receptor_off", function (pos, rules)
	rules = rules or mesecon.rules.default

	-- Call turnoff on all linking positions
	for _, rule in ipairs(mesecon.flattenrules(rules)) do
		local np = vector.add(pos, rule)
		local rulenames = mesecon.rules_link_rule_all(pos, rule)
		for _, rulename in ipairs(rulenames) do
			mesecon.vm_begin()
			mesecon.changesignal(np, minetest.get_node(np), rulename, mesecon.state.off, 2)

			-- Turnoff returns true if turnoff process was successful, no onstate receptor
			-- was found along the way. Commit changes that were made in voxelmanip. If turnoff
			-- returns true, an onstate receptor was found, abort voxelmanip transaction.
			if (mesecon.turnoff(np, rulename)) then
				mesecon.vm_commit()
			else
				mesecon.vm_abort()
			end
		end
	end
end)

function mesecon.receptor_off(pos, rules)
	mesecon.queue:add_action(pos, "receptor_off", {rules}, nil, rules)
end


print("[OK] Mesecons")

-- Deprecated stuff
-- To be removed in future releases
dofile(minetest.get_modpath("mesecons").."/legacy.lua");

--Services like turnoff receptor on dignode and so on
dofile(minetest.get_modpath("mesecons").."/services.lua");
current_modname = "intllib"
_last_run_mod = "intllib"
-- [minetest_dummy] The next line is line 1 in /home/owner/git/intllib's init.lua

-- Old multi-load method compatibility
if rawget(_G, "intllib") then return end

intllib = {
	getters = {},
	strings = {},
}


local MP = minetest.get_modpath("intllib")

dofile(MP.."/lib.lua")


local LANG = minetest.settings:get("language")
if not (LANG and (LANG ~= "")) then LANG = os.getenv("LANG") end
if not (LANG and (LANG ~= "")) then LANG = "en" end


local INS_CHAR = intllib.INSERTION_CHAR
local insertion_pattern = "("..INS_CHAR.."?)"..INS_CHAR.."(%(?)(%d+)(%)?)"

local function do_replacements(str, ...)
	local args = {...}
	-- Outer parens discard extra return values
	return (str:gsub(insertion_pattern, function(escape, open, num, close)
		if escape == "" then
			local replacement = tostring(args[tonumber(num)])
			if open == "" then
				replacement = replacement..close
			end
			return replacement
		else
			return INS_CHAR..open..num..close
		end
	end))
end

local function make_getter(msgstrs)
	return function(s, ...)
		local str
		if msgstrs then
			str = msgstrs[s]
		end
		if not str or str == "" then
			str = s
		end
		if select("#", ...) == 0 then
			return str
		end
		return do_replacements(str, ...)
	end
end


local function Getter(modname)
	modname = modname or minetest.get_current_modname()
	if not intllib.getters[modname] then
		local msgstr = intllib.get_strings(modname)
		intllib.getters[modname] = make_getter(msgstr)
	end
	return intllib.getters[modname]
end


function intllib.Getter(modname)
	local info = debug and debug.getinfo and debug.getinfo(2)
	local loc = info and info.short_src..":"..info.currentline
	minetest.log("deprecated", "intllib.Getter is deprecated."
			.." Please use intllib.make_gettext_pair instead."
			..(info and " (called from "..loc..")" or ""))
	return Getter(modname)
end


local strfind, strsub = string.find, string.sub
local langs

local function split(str, sep)
	local pos, endp = 1, #str+1
	return function()
		if (not pos) or pos > endp then return end
		local s, e = strfind(str, sep, pos, true)
		local part = strsub(str, pos, s and s-1)
		pos = e and e + 1
		return part
	end
end

function intllib.get_detected_languages()
	if langs then return langs end

	langs = { }

	local function addlang(l)
		local sep
		langs[#langs+1] = l
		sep = strfind(l, ".", 1, true)
		if sep then
			l = strsub(l, 1, sep-1)
			langs[#langs+1] = l
		end
		sep = strfind(l, "_", 1, true)
		if sep then
			langs[#langs+1] = strsub(l, 1, sep-1)
		end
	end

	local v

	v = minetest.settings:get("language")
	if v and v~="" then
		addlang(v)
	end

	v = os.getenv("LANGUAGE")
	if v then
		for item in split(v, ":") do
			langs[#langs+1] = item
		end
	end

	v = os.getenv("LANG")
	if v then
		addlang(v)
	end

	langs[#langs+1] = "en"

	return langs
end


local gettext = dofile(minetest.get_modpath("intllib").."/gettext.lua")


local function catgettext(catalogs, msgid)
	for _, cat in ipairs(catalogs) do
		local msgstr = cat and cat[msgid]
		if msgstr and msgstr~="" then
			local msg = msgstr[0]
			return msg~="" and msg or nil
		end
	end
end

local function catngettext(catalogs, msgid, msgid_plural, n)
	n = math.floor(n)
	for _, cat in ipairs(catalogs) do
		local msgstr = cat and cat[msgid]
		if msgstr then
			local index = cat.plural_index(n)
			local msg = msgstr[index]
			return msg~="" and msg or nil
		end
	end
	return n==1 and msgid or msgid_plural
end


local gettext_getters = { }
function intllib.make_gettext_pair(modname)
	modname = modname or minetest.get_current_modname()
	if gettext_getters[modname] then
		return unpack(gettext_getters[modname])
	end
	local localedir = minetest.get_modpath(modname).."/locale"
	local catalogs = gettext.load_catalogs(localedir)
	local getter = Getter(modname)
	local function gettext_func(msgid, ...)
		local msgstr = (catgettext(catalogs, msgid)
				or getter(msgid))
		return do_replacements(msgstr, ...)
	end
	local function ngettext_func(msgid, msgid_plural, n, ...)
		local msgstr = (catngettext(catalogs, msgid, msgid_plural, n)
				or getter(msgid))
		return do_replacements(msgstr, ...)
	end
	gettext_getters[modname] = { gettext_func, ngettext_func }
	return gettext_func, ngettext_func
end


local function get_locales(code)
	local ll, cc = code:match("^(..)_(..)")
	if ll then
		return { ll.."_"..cc, ll, ll~="en" and "en" or nil }
	else
		return { code, code~="en" and "en" or nil }
	end
end


function intllib.get_strings(modname, langcode)
	langcode = langcode or LANG
	modname = modname or minetest.get_current_modname()
	local msgstr = intllib.strings[modname]
	if not msgstr then
		local modpath = minetest.get_modpath(modname)
		msgstr = { }
		for _, l in ipairs(get_locales(langcode)) do
			local t = intllib.load_strings(modpath.."/locale/"..l..".txt") or { }
			for k, v in pairs(t) do
				msgstr[k] = msgstr[k] or v
			end
		end
		intllib.strings[modname] = msgstr
	end
	return msgstr
end

current_modname = "travelnet"
_last_run_mod = "travelnet"
-- [minetest_dummy] The next line is line 1 in /home/owner/git/travelnet's init.lua


--[[
    Teleporter networks that allow players to choose a destination out of a list
    Copyright (C) 2013 Sokomine

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

 Version: 2.3 (click button to dig)

 Please configure this mod in config.lua

 Changelog:
 10.03.19 - Added the extra config buttons for locked_travelnet mod.
 09.03.19 - Several PRs merged (sound added, locale changed etc.)
            Version bumped to 2.3
 26.02.19 - Removing a travelnet can now be done by clicking on a button (no need to
            wield a diamond pick anymore)
 26.02.19 - Added compatibility with MineClone2
 22.09.18 - Move up/move down no longer close the formspec.
 22.09.18 - If in creative mode, wield a diamond pick to dig the station. This avoids
            conflicts with too fast punches.
 24.12.17 - Added support for localization through intllib.
            Added localization for German (de).
            Door opening/closing can now handle more general doors.
 17.07.17 - Added more detailled licence information.
            TNT and DungeonMasters ought to leave travelnets and elevators untouched now.
            Added function to register elevator doors.
            Added elevator doors made out of tin ingots.
            Provide information about the nearest elevator network when placing a new elevator. This
              ought to make it easier to find the right spot.
            Improved formspec.
 16.07.17 - Merged several PR from others (Typo, screenshot, documentation, mesecon support, bugfix).
            Added buttons to move stations up or down in the list, independent on when they where added.
            Fixed undeclared globals.
            Changed deprecated functions set_look_yaw/pitch to current functions.
 22.07.17 - Fixed bug with locked travelnets beeing removed from the network due to not beeing recognized.
 30.08.16 - If the station the traveller just travelled to no longer exists, the player is sent back to the
            station where he/she came from.
 30.08.16 - Attaching a travelnet box to a non-existant network of another player is possible (requested by OldCoder).
            Still requires the travelnet_attach-priv.
 05.10.14 - Added an optional abm so that the travelnet network can heal itshelf in case of loss of the savefile.
            If you want to use this, set
                  travelnet.enable_abm = true
            in config.lua and edit the interval in the abm to suit your needs.
 19.11.13 - moved doors and travelnet definition into an extra file
          - moved configuration to config.lua
 05.08.13 - fixed possible crash when the node in front of the travelnet is unknown
 26.06.13 - added inventory image for elevator (created by VanessaE)
 21.06.13 - bugfix: wielding an elevator while digging a door caused the elevator_top to be placed
          - leftover floating elevator_top nodes can be removed by placing a new travelnet:elevator underneath them and removing that afterwards
          - homedecor-doors are now opened and closed correctly as well
          - removed nodes that are not intended for manual use from creative inventory
          - improved naming of station levels for the elevator
 21.06.13 - elevator stations are sorted by height instead of date of creation as is the case with travelnet boxes
          - elevator stations are named automatically
 20.06.13 - doors can be opened and closed from inside the travelnet box/elevator
          - the elevator can only move vertically; the network name is defined by its x and z coordinate
 13.06.13 - bugfix
          - elevator added (written by kpoppel) and placed into extra file
          - elevator doors added
          - groups changed to avoid accidental dig/drop on dig of node beneath
          - added new priv travelnet_remove for digging of boxes owned by other players
          - only the owner of a box or players with the travelnet_remove priv can now dig it
          - entering your own name as owner_name does no longer abort setup
 22.03.13 - added automatic detection if yaw can be set
          - beam effect is disabled by default
 20.03.13 - added inventory image provided by VanessaE
          - fixed bug that made it impossible to remove stations from the net
          - if the station a player beamed to no longer exists, the station will be removed automatically
          - with the travelnet_attach priv, you can now attach your box to the nets of other players
          - in newer versions of Minetest, the players yaw is set so that he/she looks out of the receiving box
          - target list is now centered if there are less than 9 targets
--]]

-- Required to save the travelnet data properly in all cases
if not minetest.safe_file_write then
	error("[Mod travelnet] Your Minetest version is no longer supported. (version < 0.4.17)")
end

travelnet = {};

travelnet.targets = {};
travelnet.path = minetest.get_modpath(minetest.get_current_modname())


-- Intllib
local S = dofile(travelnet.path .. "/intllib.lua")
travelnet.S = S


minetest.register_privilege("travelnet_attach", { description = S("Allow attaching travelnet boxes to travelnets of other players."), give_to_singleplayer = false});
minetest.register_privilege("travelnet_remove", { description = S("Allow removing travelnet boxes which belong to networks of other players."), give_to_singleplayer = false});

-- read the configuration
dofile(travelnet.path.."/config.lua"); -- the normal, default travelnet

travelnet.mod_data_path = minetest.get_worldpath().."/mod_travelnet.data"

-- TODO: save and restore ought to be library functions and not implemented in each individual mod!
-- called whenever a station is added or removed
travelnet.save_data = function()

   local data = minetest.serialize( travelnet.targets );

   local success = minetest.safe_file_write( travelnet.mod_data_path, data );
   if( not success ) then
      print(S("[Mod travelnet] Error: Savefile '%s' could not be written.")
         :format(travelnet.mod_data_path));
   end
end


travelnet.restore_data = function()

   local file = io.open( travelnet.mod_data_path, "r" );
   if( not file ) then
      print(S("[Mod travelnet] Error: Savefile '%s' does not exist.")
         :format(travelnet.mod_data_path));
      return;
   end

   local data = file:read("*all");
   travelnet.targets = minetest.deserialize( data );

   if( not travelnet.targets ) then
       local backup_file = travelnet.mod_data_path..".bak"
       print(S("[Mod travelnet] Error: Savefile '%s' is damaged. A backup is being saved: '%s'.")
          :format(travelnet.mod_data_path, backup_file));

       minetest.safe_file_write( backup_file, data );
       travelnet.targets = {};
   end
   file:close();
end


-- punching the travelnet updates its formspec and shows it to the player;
-- however, that would be very annoying when actually trying to dig the thing.
-- Thus, check if the player is wielding a tool that can dig nodes of the
-- group cracky
travelnet.check_if_trying_to_dig = function( puncher, node )
	-- if in doubt: show formspec
	if( not( puncher) or not( puncher:get_wielded_item())) then
		return false;
	end
	-- show menu when in creative mode
        if(   creative
	  and creative.is_enabled_for(puncher:get_player_name())
--          and (not(puncher:get_wielded_item())
--                or puncher:get_wielded_item():get_name()~="default:pick_diamond")) then
		) then
		return false;
	end
	local tool_capabilities = puncher:get_wielded_item():get_tool_capabilities();
	if( not( tool_capabilities )
	 or not( tool_capabilities["groupcaps"])
	 or not( tool_capabilities["groupcaps"]["cracky"])) then
		return false;
	end
	-- tools which can dig cracky items can start digging immediately
	return true;
end

-- minetest.chat_send_player is sometimes not so well visible
travelnet.show_message = function( pos, player_name, title, message )
	if( not( pos ) or not( player_name ) or not( message )) then
		return;
	end
	local formspec = "size[8,3]"..
		"label[3,0;"..minetest.formspec_escape( title or "Error").."]"..
		"textlist[0,0.5;8,1.5;;"..minetest.formspec_escape( message or "- nothing -")..";]"..
		"button_exit[3.5,2.5;1.0,0.5;back;"..S("Back").."]"..
		"button_exit[6.8,2.5;1.0,0.5;station_exit;"..S("Exit").."]"..
		"field[20,20;0.1,0.1;pos2str;Pos;".. minetest.pos_to_string( pos ).."]";
	minetest.show_formspec(player_name, "travelnet:show", formspec);
end

-- show the player the formspec he would see when right-clicking the node;
-- needs to be simulated this way as calling on_rightclick would not do
travelnet.show_current_formspec = function( pos, meta, player_name )
	if( not( pos ) or not( meta ) or not( player_name )) then
		return;
	end
	-- we need to supply the position of the travelnet box
	formspec = meta:get_string("formspec")..
		"field[20,20;0.1,0.1;pos2str;Pos;".. minetest.pos_to_string( pos ).."]";
	-- show the formspec manually
	minetest.show_formspec(player_name, "travelnet:show", formspec);
end

-- a player clicked on something in the formspec he was manually shown
-- (back from help page, moved travelnet up or down etc.)
travelnet.form_input_handler = function( player, formname, fields)
        if(formname == "travelnet:show" and fields and fields.pos2str) then
		local pos = minetest.string_to_pos( fields.pos2str );
		if( locks and (fields.locks_config or fields.locks_authorize)) then
			return locks:lock_handle_input( pos, formname, fields, player )
		end
		-- back button leads back to the main menu
		if( fields.back and fields.back ~= "" ) then
			return travelnet.show_current_formspec( pos,
					minetest.get_meta( pos ), player:get_player_name());
		end
		return travelnet.on_receive_fields(pos, formname, fields, player);
        end
end

-- most formspecs the travelnet uses are stored in the travelnet node itself,
-- but some may require some "back"-button functionality (i.e. help page,
-- move up/down etc.)
minetest.register_on_player_receive_fields( travelnet.form_input_handler );



travelnet.reset_formspec = function( meta )
      if( not( meta )) then
         return;
      end
      meta:set_string("infotext",       S("Travelnet-box (unconfigured)"));
      meta:set_string("station_name",   "");
      meta:set_string("station_network","");
      meta:set_string("owner",          "");
      -- some players seem to be confused with entering network names at first; provide them
      -- with a default name
      if( not( station_network ) or station_network == "" ) then
         station_network = "net1";
      end
      -- request initinal data
      meta:set_string("formspec",
		"size[10,6.0]"..
		"label[2.0,0.0;--> "..S("Configure this travelnet station").." <--]"..
		"button_exit[8.0,0.0;2.2,0.7;station_dig;"..S("Remove station").."]"..
		"field[0.3,1.2;9,0.9;station_name;"..S("Name of this station")..":;"..
			minetest.formspec_escape(station_name or "").."]"..
		"label[0.3,1.5;"..S("Name of this location (Example: \"my first house\", \"mine\", \"shop\"):").."]"..

		"field[0.3,2.8;9,0.9;station_network;"..S("Assign to Network:")..";"..
			minetest.formspec_escape(station_network or "").."]"..
		"label[0.3,3.1;"..S("You can have more than one network. If unsure, use \"%s\""):format(tostring(station_network))..".]"..
		"field[0.3,4.4;9,0.9;owner;"..S("Owned by:")..";]"..
		"label[0.3,4.7;"..S("Unless you know what you are doing, leave this empty.").."]"..
		"button_exit[1.3,5.3;1.7,0.7;station_help_setup;"..S("Help").."]"..
		"button_exit[3.8,5.3;1.7,0.7;station_set;"..S("Save").."]"..
		"button_exit[6.3,5.3;1.7,0.7;station_exit;"..S("Exit").."]");
end


travelnet.update_formspec = function( pos, puncher_name, fields )
   local meta = minetest.get_meta(pos);

   local this_node   = minetest.get_node( pos );
   local is_elevator = false;

   if( this_node ~= nil and this_node.name == 'travelnet:elevator' ) then
      is_elevator = true;
   end

   if( not( meta )) then
      return;
   end

   local owner_name      = meta:get_string( "owner" );
   local station_name    = meta:get_string( "station_name" );
   local station_network = meta:get_string( "station_network" );

   if(  not( owner_name )
     or not( station_name ) or station_network == ''
     or not( station_network )) then


      if( is_elevator == true ) then
         travelnet.add_target( nil, nil, pos, puncher_name, meta, owner_name );
         return;
      end

--      minetest.chat_send_player(puncher_name, "DEBUG DATA: owner: "..(owner_name or "?")..
--                                                  " station_name: "..(station_name or "?")..
--                                               " station_network: "..(station_network or "?")..".");
-- minetest.chat_send_player(puncher_name, "data: "..minetest.serialize(  travelnet.targets ));


      travelnet.reset_formspec( meta );
      travelnet.show_message( pos, puncher_name, "Error", S("Update failed! Changes reverted."));
      return;
   end

   -- if the station got lost from the network for some reason (savefile corrupted?) then add it again
   if(  not( travelnet.targets[ owner_name ] )
     or not( travelnet.targets[ owner_name ][ station_network ] )
     or not( travelnet.targets[ owner_name ][ station_network ][ station_name ] )) then

      -- first one by this player?
      if( not( travelnet.targets[ owner_name ] )) then
         travelnet.targets[       owner_name ] = {};
      end

      -- first station on this network?
      if( not( travelnet.targets[ owner_name ][ station_network ] )) then
         travelnet.targets[       owner_name ][ station_network ] = {};
      end


      local zeit = meta:get_int("timestamp");
      if( not( zeit) or type(zeit)~="number" or zeit<100000 ) then
         zeit = os.time();
      end

      -- add this station
      travelnet.targets[ owner_name ][ station_network ][ station_name ] = {pos=pos, timestamp=zeit };

      minetest.chat_send_player(owner_name,
         S("Station '%s' reconnected to network '%s'."
         ):format(station_name, station_network)
      );
      travelnet.save_data();
   end


   -- add name of station + network + owner + update-button
   local zusatzstr = "";
   local trheight = "10";
   if( this_node and this_node.name=="locked_travelnet:travelnet" and locks) then
      zusatzstr = "field[0.3,11;6,0.7;locks_sent_lock_command;"..S("Locked travelnet. Type /help for help:")..";]"..
		  locks.get_authorize_button(10,"10.5")..
		  locks.get_config_button(11,"10.5")
      trheight = "11.5";
   end
   local formspec = "size[12,"..trheight.."]"..
                            "label[3.3,0.0;"..S("Travelnet-Box")..":]".."label[6.3,0.0;"..S("Punch box to update target list.").."]"..
                            "label[0.3,0.4;"..S("Name of this station:").."]".."label[6.3,0.4;"..minetest.formspec_escape(station_name or "?").."]"..
                            "label[0.3,0.8;"..S("Assigned to Network:").."]" .."label[6.3,0.8;"..minetest.formspec_escape(station_network or "?").."]"..
                            "label[0.3,1.2;"..S("Owned by:").."]"            .."label[6.3,1.2;"..minetest.formspec_escape(owner_name or "?").."]"..
                            "label[3.3,1.6;"..S("Choose a destination:").."]"..
			    zusatzstr;
--                            "button_exit[5.3,0.3;8,0.8;do_update;Punch box to update destination list. Click on target to travel there.]"..
   local x = 0;
   local y = 0;
   local i = 0;


   -- collect all station names in a table
   local stations = {};

   for k,v in pairs( travelnet.targets[ owner_name ][ station_network ] ) do
      table.insert( stations, k );
   end
   -- minetest.chat_send_player(puncher_name, "stations: "..minetest.serialize( stations ));

   local ground_level = 1;
   if( is_elevator ) then
      table.sort( stations, function(a,b) return travelnet.targets[ owner_name ][ station_network ][ a ].pos.y >
                                                 travelnet.targets[ owner_name ][ station_network ][ b ].pos.y  end);
      -- find ground level
      local vgl_timestamp = 999999999999;
      for index,k in ipairs( stations ) do
         if( not( travelnet.targets[ owner_name ][ station_network ][ k ].timestamp )) then
            travelnet.targets[ owner_name ][ station_network ][ k ].timestamp = os.time();
         end
         if( travelnet.targets[ owner_name ][ station_network ][ k ].timestamp < vgl_timestamp ) then
            vgl_timestamp = travelnet.targets[ owner_name ][ station_network ][ k ].timestamp;
            ground_level  = index;
         end
      end
      for index,k in ipairs( stations ) do
         if( index == ground_level ) then
            travelnet.targets[ owner_name ][ station_network ][ k ].nr = S('G');
         else
            travelnet.targets[ owner_name ][ station_network ][ k ].nr = tostring( ground_level - index );
         end
      end

   else
      -- sort the table according to the timestamp (=time the station was configured)
      table.sort( stations, function(a,b) return travelnet.targets[ owner_name ][ station_network ][ a ].timestamp <
                                                 travelnet.targets[ owner_name ][ station_network ][ b ].timestamp  end);
   end

   -- does the player want to move this station one position up in the list?
   -- only the owner and players with the travelnet_attach priv can change the order of the list
   -- Note: With elevators, only the "G"(round) marking is actually moved
   if( fields
       and (fields.move_up or fields.move_down)
       and owner_name
       and owner_name ~= ""
       and ((owner_name == puncher_name)
            or (minetest.check_player_privs(puncher_name, {travelnet_attach=true})))
     ) then

      local current_pos = -1;
      for index,k in ipairs( stations ) do
         if( k==station_name ) then
            current_pos = index;
         end
      end

      local swap_with_pos = -1;
      if( fields.move_up ) then
         swap_with_pos = current_pos - 1;
      else
         swap_with_pos = current_pos + 1;
      end
      -- handle errors
      if(     swap_with_pos < 1) then
         travelnet.show_message( pos, puncher_name, "Info", S("This station is already the first one on the list."));
         return;
      elseif( swap_with_pos > #stations ) then
         travelnet.show_message( pos, puncher_name, "Info", S("This station is already the last one on the list."));
         return;
      else
         -- swap the actual data by which the stations are sorted
         local old_timestamp = travelnet.targets[ owner_name ][ station_network ][ stations[swap_with_pos]].timestamp;
         travelnet.targets[    owner_name ][ station_network ][ stations[swap_with_pos]].timestamp =
            travelnet.targets[ owner_name ][ station_network ][ stations[current_pos  ]].timestamp;
         travelnet.targets[    owner_name ][ station_network ][ stations[current_pos  ]].timestamp =
            old_timestamp;

         -- for elevators, only the "G"(round) marking is moved; no point in swapping stations
         if( not( is_elevator )) then
            -- actually swap the stations
            local old_val = stations[ swap_with_pos ];
            stations[ swap_with_pos ] = stations[ current_pos ];
            stations[ current_pos   ] = old_val;
         end

         -- store the changed order
         travelnet.save_data();
      end
   end

   -- if there are only 8 stations (plus this one), center them in the formspec
   if( #stations < 10 ) then
      x = 4;
   end

   for index,k in ipairs( stations ) do

      -- check if there is an elevator door in front that needs to be opened
      local open_door_cmd = false;
      if( k==station_name ) then
         open_door_cmd = true;
      end

      if( k ~= station_name or open_door_cmd) then
         i = i+1;

         -- new column
         if( y==8 ) then
            x = x+4;
            y = 0;
         end

         if( open_door_cmd ) then
            formspec = formspec .."button_exit["..(x)..","..(y+2.5)..";1,0.5;open_door;<>]"..
                                  "label["..(x+0.9)..","..(y+2.35)..";"..tostring( k ).."]";
         elseif( is_elevator ) then
            formspec = formspec .."button_exit["..(x)..","..(y+2.5)..";1,0.5;target;"..tostring( travelnet.targets[ owner_name ][ station_network ][ k ].nr ).."]"..
                                  "label["..(x+0.9)..","..(y+2.35)..";"..tostring( k ).."]";
         else
            formspec = formspec .."button_exit["..(x)..","..(y+2.5)..";4,0.5;target;"..k.."]";
         end

--         if( is_elevator ) then
--            formspec = formspec ..' ('..tostring( travelnet.targets[ owner_name ][ station_network ][ k ].pos.y )..'m)';
--         end
--         formspec = formspec .. ']';

         y = y+1;
         --x = x+4;
      end
   end
   formspec = formspec..
         "label[8.0,1.6;"..S("Position in list:").."]"..
         "button_exit[11.3,0.0;1.0,0.5;station_exit;"..S("Exit").."]"..
         "button_exit[10.0,0.5;2.2,0.7;station_dig;"..S("Remove station").."]"..
         "button[9.6,1.6;1.4,0.5;move_up;"..S("move up").."]"..
         "button[10.9,1.6;1.4,0.5;move_down;"..S("move down").."]";

   meta:set_string( "formspec", formspec );

   meta:set_string( "infotext",
      S("Station '%s' on travelnet '%s' (owned by %s) is ready."
        .. " Right-click to travel, punch to update."
      ):format(tostring( station_name ), tostring( station_network ),
               tostring( owner_name ))
   );
   -- show the player the updated formspec
   travelnet.show_current_formspec( pos, meta, puncher_name );
end



-- add a new target; meta is optional
travelnet.add_target = function( station_name, network_name, pos, player_name, meta, owner_name )

   -- if it is an elevator, determine the network name through x and z coordinates
   local this_node   = minetest.get_node( pos );
   local is_elevator = false;

   if( this_node.name == 'travelnet:elevator' ) then
--      owner_name   = '*'; -- the owner name is not relevant here
      is_elevator  = true;
      network_name = tostring( pos.x )..','..tostring( pos.z );
      if( not( station_name ) or station_name == '' ) then
         station_name = S('at %s m'):format(tostring( pos.y ));
      end
   end

   if( station_name == "" or not(station_name )) then
      travelnet.show_message( pos, player_name, S("Error"), S("Please provide a name for this station." ));
      return;
   end

   if( network_name == "" or not( network_name )) then
      travelnet.show_message( pos, player_name, S("Error"),
	S("Please provide a new or existing network to which this station should connect."));
      return;
   end

   if(     owner_name == nil or owner_name == '' or owner_name == player_name) then
      owner_name = player_name;

   elseif( is_elevator ) then -- elevator networks
      owner_name = player_name;

   elseif( not( minetest.check_player_privs(player_name, {interact=true}))) then

      travelnet.show_message( pos, player_name, S("Error"),
         S( "Access is denied."
            .. " There is no player with interact privilege named '%s'."
         ):format(tostring( player_name ))
      );
      return;

   elseif( not( minetest.check_player_privs(player_name, {travelnet_attach=true}))
       and not( travelnet.allow_attach( player_name, owner_name, network_name ))) then

      travelnet.show_message( pos, player_name, S("Error"),
         S("Access is denied. You do not have the travelnet_attach priv"
         .. " which is required to attach your box"
         .. " to the network of someone else."));
      return;
   end

   -- first one by this player?
   if( not( travelnet.targets[ owner_name ] )) then
      travelnet.targets[       owner_name ] = {};
   end

   -- first station on this network?
   if( not( travelnet.targets[ owner_name ][ network_name ] )) then
      travelnet.targets[       owner_name ][ network_name ] = {};
   end

   -- lua doesn't allow efficient counting here
   local anz = 0;
   for k,v in pairs( travelnet.targets[ owner_name ][ network_name ] ) do

      if( k == station_name ) then
         travelnet.show_message( pos, player_name, S("Error"),
            S("A station named '%s' already exists on this network."
              .. " Please choose a different name!"):format(station_name)
         );
         return;
      end

      anz = anz + 1;
   end

   -- we don't want too many stations in the same network because that would get confusing when displaying the targets
   if( anz+1 > travelnet.MAX_STATIONS_PER_NETWORK ) then
      travelnet.show_message( pos, player_name, S("Error"),
         S("Network '%s' already contains the maximum number (=%s)"
            .. " of allowed stations per network."
            .. " Please choose a different/new network name."
         ):format(network_name, travelnet.MAX_STATIONS_PER_NETWORK)
      );
      return;
   end

   -- add this station
   travelnet.targets[ owner_name ][ network_name ][ station_name ] = {pos=pos, timestamp=os.time() };

   -- do we have a new node to set up? (and are not just reading from a safefile?)
   if( meta ) then

      minetest.chat_send_player(player_name,
         S("Station '%s' connected to network '%s'"
         .. ", which now consists of %s station(s)."
         ):format(station_name, network_name, anz+1)
      );

      meta:set_string( "station_name",    station_name );
      meta:set_string( "station_network", network_name );
      meta:set_string( "owner",           owner_name );
      meta:set_int( "timestamp",       travelnet.targets[ owner_name ][ network_name ][ station_name ].timestamp);

      meta:set_string("formspec",
                     "size[12,10]"..
                     "field[0.3,0.6;6,0.7;station_name;"..S("Station:")..";"..   minetest.formspec_escape(meta:get_string("station_name")).."]"..
                     "field[0.3,3.6;6,0.7;station_network;"..S("Network:")..";"..minetest.formspec_escape(meta:get_string("station_network")).."]" );

      -- display a list of all stations that can be reached from here
      travelnet.update_formspec( pos, player_name, nil );

      -- save the updated network data in a savefile over server restart
      travelnet.save_data();
   end
end



-- allow doors to open
travelnet.open_close_door = function( pos, player, mode )

   local this_node = minetest.get_node_or_nil( pos );
   -- give up if the area is *still* not loaded
   if( this_node == nil ) then
      return
   end
   local pos2 = {x=pos.x,y=pos.y,z=pos.z};

   if(     this_node.param2 == 0 ) then pos2 = {x=pos.x,y=pos.y,z=(pos.z-1)};
   elseif( this_node.param2 == 1 ) then pos2 = {x=(pos.x-1),y=pos.y,z=pos.z};
   elseif( this_node.param2 == 2 ) then pos2 = {x=pos.x,y=pos.y,z=(pos.z+1)};
   elseif( this_node.param2 == 3 ) then pos2 = {x=(pos.x+1),y=pos.y,z=pos.z};
   end

   local door_node = minetest.get_node( pos2 );
   if( door_node ~= nil and door_node.name ~= 'ignore' and door_node.name ~= 'air' and minetest.registered_nodes[ door_node.name ] ~= nil and minetest.registered_nodes[ door_node.name ].on_rightclick ~= nil) then

      -- at least for homedecor, same facedir would mean "door closed"

      -- do not close the elevator door if it is already closed
      if( mode==1 and ( string.sub( door_node.name, -7 ) == '_closed'
                     -- handle doors that change their facedir
                     or ( door_node.param2 == ((this_node.param2 + 2)%4)
                      and door_node.name ~= 'travelnet:elevator_door_glass_open'
                      and door_node.name ~= 'travelnet:elevator_door_tin_open'
                      and door_node.name ~= 'travelnet:elevator_door_steel_open'))) then
         return;
      end
      -- do not open the doors if they are already open (works only on elevator-doors; not on doors in general)
      if( mode==2 and ( string.sub( door_node.name, -5 ) == '_open'
                     -- handle doors that change their facedir
                     or ( door_node.param2 ~= ((this_node.param2 + 2)%4)
                      and door_node.name ~= 'travelnet:elevator_door_glass_closed'
                      and door_node.name ~= 'travelnet:elevator_door_tin_closed'
                      and door_node.name ~= 'travelnet:elevator_door_steel_closed'))) then
         return;
      end

      if( mode==2 ) then
         minetest.after( 1, minetest.registered_nodes[ door_node.name ].on_rightclick, pos2, door_node, player );
      else
         minetest.registered_nodes[ door_node.name ].on_rightclick(pos2, door_node, player);
      end
   end
end


travelnet.on_receive_fields = function(pos, formname, fields, player)
   if( not( pos )) then
      return;
   end
   local meta = minetest.get_meta(pos);

   local name = player:get_player_name();

   -- the player wants to quit/exit the formspec; do not save/update anything
   if( fields and fields.station_exit and fields.station_exit ~= "" ) then
      return;
   end

   -- show special locks buttons if needed
   if( locks and (fields.locks_config or fields.locks_authorize)) then
      return locks:lock_handle_input( pos, formname, fields, player )
   end

   -- show help text
   if( fields and fields.station_help_setup and fields.station_help_setup ~= "") then
      -- simulate right-click
      local node = minetest.get_node( pos );
      if( node and node.name and minetest.registered_nodes[ node.name ] ) then
         travelnet.show_message( pos, name, "--> Help <--",
-- TODO: actually add help page
		S("No help available yet."));
      end
      return;
   end

   -- the player wants to remove the station
   if( fields.station_dig ) then
      local owner = meta:get_string( "owner" );

      local node = minetest.get_node(pos)
      local description = "station"
      if( node and node.name and node.name == "travelnet:travelnet") then
         description = "travelnet box"
      elseif( node and node.name and node.name == "travelnet:elevator") then
         description = "elevator"
      elseif( node and node.name and node.name == "locked_travelnet:travelnet") then
         description = "locked travelnet"
      else
         minetest.chat_send_player(name, "Error: Unkown node.");
         return
      end
      -- players with travelnet_remove priv can dig the station
      if( not(minetest.check_player_privs(name, {travelnet_remove=true}))
       -- the function travelnet.allow_dig(..) may allow additional digging
       and not(travelnet.allow_dig( name, owner, network_name ))
       -- the owner can remove the station
       and owner ~= name
       -- stations without owner can be removed by anybody
       and owner ~= "") then
         minetest.chat_send_player(name, S("This %s belongs to %s. You can't remove it."):format(description, tostring( meta:get_string('owner'))));
         return
      end

      local pinv = player:get_inventory()
      if(not(pinv:room_for_item("main", node.name))) then
         minetest.chat_send_player(name, S("You do not have enough room in your inventory."));
         return
      end

      -- give the player the box
      pinv:add_item("main", node.name)
      -- remove the box from the data structure
      travelnet.remove_box( pos, nil, meta:to_table(), player );
      -- remove the node as such
      minetest.remove_node(pos)
      return;
   end




   -- if the box has not been configured yet
   if( meta:get_string("station_network")=="" ) then

      travelnet.add_target( fields.station_name, fields.station_network, pos, name, meta, fields.owner );
      return;
   end

   if( fields.open_door ) then
      travelnet.open_close_door( pos, player, 0 );
      return;
   end

   -- the owner or players with the travelnet_attach priv can move stations up or down in the list
   if( fields.move_up or fields.move_down) then
      travelnet.update_formspec( pos, name, fields );
      return;
   end

   if( not( fields.target )) then
      minetest.chat_send_player(name, S("Choose a destination."));
      return;
   end


   -- if there is something wrong with the data
   local owner_name      = meta:get_string( "owner" );
   local station_name    = meta:get_string( "station_name" );
   local station_network = meta:get_string( "station_network" );

   if(  not( owner_name  )
     or not( station_name )
     or not( station_network )
     or not( travelnet.targets[ owner_name ] )
     or not( travelnet.targets[ owner_name ][ station_network ] )) then


      if(     owner_name
          and station_name
          and station_network ) then
            travelnet.add_target( station_name, station_network, pos, owner_name, meta, owner_name );
      else
         minetest.chat_send_player(name, S("Error")..": "..
				S("There is something wrong with the configuration of this station.")..
                                      " DEBUG DATA: owner: "..(  owner_name or "?")..
                                      " station_name: "..(station_name or "?")..
                                      " station_network: "..(station_network or "?")..".");
         return
      end
   end

   if(  not( owner_name )
     or not( station_network )
     or not( travelnet.targets )
     or not( travelnet.targets[ owner_name ] )
     or not( travelnet.targets[ owner_name ][ station_network ] )) then
      minetest.chat_send_player(name, S("Error")..": "..
				S("This travelnet is lacking data and/or improperly configured."));
      print( "ERROR: The travelnet at "..minetest.pos_to_string( pos ).." has a problem: "..
                                      " DATA: owner: "..(  owner_name or "?")..
                                      " station_name: "..(station_name or "?")..
                                      " station_network: "..(station_network or "?")..".");
      return;
   end

   local this_node = minetest.get_node( pos );
   if( this_node ~= nil and this_node.name == 'travelnet:elevator' ) then
      for k,v in pairs( travelnet.targets[ owner_name ][ station_network ] ) do
         if( travelnet.targets[ owner_name ][ station_network ][ k ].nr  --..' ('..tostring( travelnet.targets[ owner_name ][ station_network ][ k ].pos.y )..'m)'
               == fields.target) then
            fields.target = k;
         end
      end
   end


   -- if the target station is gone
   if( not( travelnet.targets[ owner_name ][ station_network ][ fields.target ] )) then

      minetest.chat_send_player(name,
			S("Station '%s' does not exist (anymore?) on this network."
         ):format( fields.target or "?")
      );
      travelnet.update_formspec( pos, name, nil );
      return;
   end


   if( not( travelnet.allow_travel( name, owner_name, station_network, station_name, fields.target ))) then
      return;
   end
   minetest.chat_send_player(name, S("Initiating transfer to station '%s'."):format( fields.target or "?"));



   if( travelnet.travelnet_sound_enabled ) then
      if ( this_node.name == 'travelnet:elevator' ) then
         minetest.sound_play("travelnet_bell", {pos = pos, gain = 0.75, max_hear_distance = 10,});
      else
         minetest.sound_play("travelnet_travel", {pos = pos, gain = 0.75, max_hear_distance = 10,});
      end
   end
   if( travelnet.travelnet_effect_enabled ) then
      minetest.add_entity( {x=pos.x,y=pos.y+0.5,z=pos.z}, "travelnet:effect"); -- it self-destructs after 20 turns
   end

   -- close the doors at the sending station
   travelnet.open_close_door( pos, player, 1 );

   -- transport the player to the target location
   local target_pos = travelnet.targets[ owner_name ][ station_network ][ fields.target ].pos;
   player:move_to( target_pos, false);

   if( travelnet.travelnet_effect_enabled ) then
      minetest.add_entity( {x=target_pos.x,y=target_pos.y+0.5,z=target_pos.z}, "travelnet:effect"); -- it self-destructs after 20 turns
   end


   -- check if the box has at the other end has been removed.
   local node2 = minetest.get_node_or_nil(  target_pos );
   if( node2 ~= nil and node2.name ~= 'ignore' and node2.name ~= 'travelnet:travelnet' and node2.name ~= 'travelnet:elevator' and node2.name ~= "locked_travelnet:travelnet" and node2.name ~= "travelnet:travelnet_private") then

      -- provide information necessary to identify the removed box
      local oldmetadata = { fields = { owner           = owner_name,
                                       station_name    = fields.target,
                                       station_network = station_network }};

      travelnet.remove_box( target_pos, nil, oldmetadata, player );
      -- send the player back as there's no receiving travelnet
      player:move_to( pos, false );

   else
      travelnet.rotate_player( target_pos, player, 0 )
   end
end

travelnet.rotate_player = function( target_pos, player, tries )
   -- try later when the box is loaded
   local node2 = minetest.get_node_or_nil( target_pos );
   if( node2 == nil ) then
      if( tries < 30 ) then
         minetest.after( 0, travelnet.rotate_player, target_pos, player, tries+1 )
      end
      return
   end

   -- play sound at the target position as well
   if( travelnet.travelnet_sound_enabled ) then
      if ( node2.name == 'travelnet:elevator' ) then
         minetest.sound_play("travelnet_bell", {pos = target_pos, gain = 0.75, max_hear_distance = 10,});
      else
         minetest.sound_play("travelnet_travel", {pos = target_pos, gain = 0.75, max_hear_distance = 10,});
      end
   end

   -- do this only on servers where the function exists
   if( player.set_look_horizontal ) then
      -- rotate the player so that he/she can walk straight out of the box
      local yaw    = 0;
      local param2 = node2.param2;
      if( param2==0 ) then
         yaw = 180;
      elseif( param2==1 ) then
         yaw = 90;
      elseif( param2==2 ) then
         yaw = 0;
      elseif( param2==3 ) then
         yaw = 270;
      end

      player:set_look_horizontal( math.rad( yaw ));
      player:set_look_vertical( math.rad( 0 ));
   end

   travelnet.open_close_door( target_pos, player, 2 );
end


travelnet.remove_box = function( pos, oldnode, oldmetadata, digger )

   if( not( oldmetadata ) or oldmetadata=="nil" or not(oldmetadata.fields)) then
      minetest.chat_send_player( digger:get_player_name(), S("Error")..": "..
		S("Travelnet could not find information about the station that is to be removed."));
      return;
   end

   local owner_name      = oldmetadata.fields[ "owner" ];
   local station_name    = oldmetadata.fields[ "station_name" ];
   local station_network = oldmetadata.fields[ "station_network" ];

   -- station is not known? then just remove it
   if(  not( owner_name )
     or not( station_name )
     or not( station_network )
     or not( travelnet.targets[ owner_name ] )
     or not( travelnet.targets[ owner_name ][ station_network ] )) then

      minetest.chat_send_player( digger:get_player_name(), S("Error")..": "..
		S("Travelnet could not find the station that is to be removed."));
      return;
   end

   travelnet.targets[ owner_name ][ station_network ][ station_name ] = nil;

   -- inform the owner
   minetest.chat_send_player( owner_name,
		S("Station '%s' disconnected from network '%s'."
      ):format(station_name, station_network)
   );
   if( digger ~= nil and owner_name ~= digger:get_player_name() ) then
      minetest.chat_send_player( digger:get_player_name(),
         S("Station '%s' disconnected from network '%s'."
         ):format(station_name, station_network)
      );
   end

   -- save the updated network data in a savefile over server restart
   travelnet.save_data();
end



travelnet.can_dig = function( pos, player, description )
   -- forbid digging of the travelnet
   return false;
end

-- obsolete function
travelnet.can_dig_old = function( pos, player, description )
   if( not( player )) then
      return false;
   end
   local name          = player:get_player_name();
   local meta          = minetest.get_meta( pos );
   local owner         = meta:get_string('owner');
   local network_name  = meta:get_string( "station_network" );

   -- in creative mode, accidental digging could happen too easily when trying to update the net
   if(creative and creative.is_enabled_for(player:get_player_name())) then
     -- only a diamond pick can dig the travelnet
     if( not(player:get_wielded_item())
          or player:get_wielded_item():get_name()~="default:pick_diamond") then
        return false;
     end
   end

   -- players with that priv can dig regardless of owner
   if( minetest.check_player_privs(name, {travelnet_remove=true})
       or travelnet.allow_dig( name, owner, network_name )) then
      return true;
   end

   if( not( meta ) or not( owner) or owner=='') then
      minetest.chat_send_player(name,
         S("This %s has not been configured yet."
           .. " Please set it up first to claim it."
           .. " You can only remove stations you own."
         ):format(description)
      );
      return false;

   elseif( owner ~= name ) then
      minetest.chat_send_player(name, S("This %s belongs to %s. You can't remove it."):format(description, tostring( meta:get_string('owner'))));
      return false;
   end
   return true;
end





if( travelnet.travelnet_effect_enabled ) then
  minetest.register_entity( 'travelnet:effect', {

    hp_max = 1,
    physical = false,
    weight = 5,
    collisionbox = {-0.4,-0.5,-0.4, 0.4,1.5,0.4},
    visual = "upright_sprite",
    visual_size = {x=1, y=2},
--    mesh = "model",
    textures = { "travelnet_flash.png" }, -- number of required textures depends on visual
--    colors = {}, -- number of required colors depends on visual
    spritediv = {x=1, y=1},
    initial_sprite_basepos = {x=0, y=0},
    is_visible = true,
    makes_footstep_sound = false,
    automatic_rotate = true,

    anz_rotations = 0,

    on_step = function( self, dtime )
       -- this is supposed to be more flickering than smooth animation
       self.object:set_yaw( self.object:get_yaw()+1);
       self.anz_rotations = self.anz_rotations + 1;
       -- eventually self-destruct
       if( self.anz_rotations > 15 ) then
          self.object:remove();
       end
    end
  })
end


if( travelnet.travelnet_enabled ) then
   dofile(travelnet.path.."/travelnet.lua"); -- the travelnet node definition
end
if( travelnet.elevator_enabled ) then
   dofile(travelnet.path.."/elevator.lua");  -- allows up/down transfers only
end
if( travelnet.doors_enabled ) then
   dofile(travelnet.path.."/doors.lua");     -- doors that open and close automatically when the travelnet or elevator is used
end

if( travelnet.abm_enabled ) then
   dofile(travelnet.path.."/restore_network_via_abm.lua"); -- restore travelnet data when players pass by broken networks
end

-- upon server start, read the savefile
travelnet.restore_data();
print("* [minetest_dummy] Lua init completed for: ['minetest_dummy', 'minetest_dummy.extras', 'builtin', 'travelnet', 'mesecons', 'default', 'player_api', 'intllib']")

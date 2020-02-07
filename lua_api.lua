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
		print("	 * ERROR: the biome '"..biome.."' is not registered yet during add_something_to_biome (def[name_of_name_value]='"..name.."')")
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
			-- print("    * adding an ore '"..def.ore.."' to biome '"..biome.."'")
			add_something_to_biome(def.ore, biome, "ores", def)
		end
	 else
		biome = "any"
		print("  * adding an ore '"..def.ore.."' for any biome")
		add_something_to_biome(def.ore, biome, "ores", def)
	 end
	-- _registered_ores[def.name] = def
end

local _registered_decorations = {}
function _G.dummy_core.register_decoration(def)
	-- TODO: make function that replaces both this and register_ore which both this and that call.
	-- takes decoration def
	-- print("  * [minetest_dummy] is pretending to register decoration: "..table.tostring(def))  -- table.tostring is from minetest_dummy/extras.lua
	local name = def.decoration
	if name == nil then
		name = def.name
		print("    * [minetest_dummy] WARNING: using def.decoration instead of def.name for "..name)
	end
	if def.biomes ~= nil then
		for i = 1, #def.biomes do
			biome = def.biomes[i]
			-- print("    * adding a decoration '"..name.."' to biome '"..biome.."'")
			add_something_to_biome(name, biome, "decorations", def)
		end
	 else
		biome = "any"
		print("    * adding a decoration '"..name.."' for any biome")
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
		-- print("* trying to find " .. str .. " in '" .. mod_parents[i] .. "'")
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
	return _mapgen_settings_values[str]  -- minetest_dummy's python code generates this!
end


function dummy_core.setting_get(str)
	return _settings_values[str]  -- minetest_dummy's python code generates this!
end
function dummy_core.setting_getbool(str)
	return _settings_values[str]  -- minetest_dummy's python code generates this!
end
function dummy_core.setting_set(str, v)
	_settings_values[str] = v
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

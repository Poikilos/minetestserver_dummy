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

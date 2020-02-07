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

--Override standard Lua behavior.


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
   print("* [minetest_dummy lua] WARNING: an assertion failed. This is probably because setfenv is fake in minetest_dummy. "..debug.traceback())
   return v
end
-- _G.assert = assert

pairs = orderedPairs  -- This is necessary to prevent a failed assertion in minetest 5 where it tests core.privs_to_string at the end of builtin/common/misc_helpers.lua

travelnet = {};

travelnet.targets = {};
travelnet.path = "/home/owner/git/travelnet"
-- local S = dofile(travelnet.path .. "/intllib.lua")
local S = dofile("/home/owner/git/minetest_dummy/unused/intllib_substitute.lua")

-- local i18n = require 'i18n'
-- local S = require 'i18n'
-- local S = i18n.translate
require 'locales' -- if using a separate file for the locales, require it too

-- print( i18n.translate('helloWorld') ) -- Hello world
-- S.setLocale('es')
-- using i18n() instead of i18n.translate()
print( S('helloWorld') ) -- Hola mundo
-- print( S('There is not enough vertical space to place the travelnet box!') ) -- Hola mundo

-- The MIT License (MIT)
-- 
-- Copyright (c) 2014, Cyril David <cyx@cyx.is>
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

-- constants used in this module
local SEP = "&"
local EQ = "="

local uri = require("lib/uri-856fa34")

-- aggressive caching of global table methods for performance
local format = string.format
local gmatch = string.gmatch
local find   = string.find
local sub    = string.sub
local concat = table.concat
local insert = table.insert

local encode = uri.encode
local decode = uri.decode

-- private: helper function to parse a given query string
-- and yield key / val pairs.
-- 
-- sep = defaults to &
-- eq = defaults to =
-- 
-- returns: function iterator
local function iterate(str, sep, eq)
	sep = sep or SEP
	eq = eq or EQ

	-- use this to split on separator
	local pattern = format("[^%s]+", sep)

	-- calleable for use with our iterator return value
	local fn = gmatch(str, pattern)

	-- iterator is stateful style using this function closure
	-- as it's state. fn will keep returning `data` until it's done.
	return function()
		local data = fn()

		if data then
			local key, val
			local pos = find(data, eq)

			if pos then
				key = sub(data, 1, pos - 1)
				val = sub(data, pos + 1)
			else
				key = data
				val = ""
			end

			return decode(key), decode(val)
		end
	end
end

-- Builds non hierarchical data given a table of str => array pairs.
--
-- Usage:
--
--	local str = querystring.build({ a = {"a"}, b = {"b"}, c = { 1, 2, 3 } })
--	assert("a=a&b=b&c=1&c=2&c=3" == str)
--
local function build(dict, sep)
	sep = sep or SEP

	local query = {}

	for key, val in pairs(dict) do
		for _, v in ipairs(val) do
			insert(query, format("%s=%s",
				encode(tostring(key)),
				encode(tostring(v))
			))
		end
	end

	return concat(query, sep)
end

-- Parses the querystring to a single level table (non hierarchical data).
--
-- Usage:
--	local t = querystring.parse("a=a&b=&c=1&c=2&c=3")
--
--	assert(t.a[1] == "a")
--	assert(t.b[1] == "b")
--	assert(t.c[1] == "1")
--	assert(t.c[2] == "2")
--	assert(t.c[3] == "3")
--
local function parse(str, sep, eq)
	local result = {}

	for key, val in iterate(str, sep, eq) do
		-- initialize: every value is an array
		result[key] = result[key] or {}

		-- append the value to the array
		insert(result[key], val)
	end

	return result
end

local module = {
	build = build,
	parse = parse
}

return module

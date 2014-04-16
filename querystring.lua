-- constants used in this module
local SEP = "&"
local EQ = "="

local uri = require("lib/uri-856fa34")

-- aggressive caching of global table methods for performance
local format = string.format
local gsub   = string.gsub
local gmatch = string.gmatch
local find   = string.find
local sub    = string.sub
local concat = table.concat
local insert = table.insert

local encode = uri.encode
local decode = uri.decode

-- forward declaration for all util functions in this module
local util = {}

-- Builds non hierarchical data as described in RFC 3986
--
-- @see http://tools.ietf.org/html/rfc3986#section-3.4
--
-- Usage:
--
--	local str = querystring.build({ a = "a", b = "b", c = { 1, 2, 3 } })
--	assert("a=a&b=b&c=1&c=2&c=3" == str)
--
local function build(dict, sep)
	sep = sep or SEP

	local query = {}

	for name, value in pairs(dict) do
		name = encode(tostring(name))

		if util.isarray(value) then
			for _, v in ipairs(value) do
				insert(query, format("%s=%s", name, encode(tostring(v))))
			end
		else
			local value = encode(tostring(value))

			if value ~= "" then
				insert(query, format("%s=%s", name, value))
			else
				insert(query, name)
			end
		end
	end

	return concat(query, sep)
end

-- Parses the querystring to a single level table (non hierarchical data).
--
-- Usage:
--	local t = querystring.parse("a=a&b=&c=1&c=2&c=3")
--
--	assert(t.a == "a")
--	assert(t.b == "b")
--	assert(t.c == nil)
--
-- @see http://tools.ietf.org/html/rfc3986#section-3.4
--
local function parse(str, sep, eq)
	local lists = {}
	local result = { __lists = lists }

	for key, val in util.parse_iter(str, sep, eq) do
		if result[key] == nil then
			result[key] = val
		end

		lists[key] = lists[key] or {}

		insert(lists[key], val)
	end

	local function list(self, key)
		return self.__lists[key]
	end

	setmetatable(result, { __index = { list = list }})

	return result
end

-- For the context of this module, an array is simply any object
-- with a length property.
--
-- The only way to get this with a dict is if you assign a number
-- as a key, which shouldn't happen in this case since all keys are
-- strings.
function util.isarray(obj)
	return type(obj) == "table" and #obj > 0
end

function util.split(str, sep)
	local pattern = format("[^%s]+", sep)
	
	return gmatch(str, pattern)
end

function util.parse_iter(str, sep, eq)
	sep = sep or SEP
	eq = eq or EQ
	
	local fn = util.split(str, sep)

	return function()
		local chunk = fn()

		if chunk then
			local key, val = util.split_once(chunk, eq)

			key = decode(key)
			val = decode(val)

			return key, val
		end
	end
end

function util.split_once(str, sep)
	local idx = find(str, sep)

	if not idx then
		return str, ""
	end

	return sub(str, 1, idx - 1), sub(str, idx + 1)
end

local module = {
	build = build,
	parse = parse
}

return module

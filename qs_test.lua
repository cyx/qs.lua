local qs = require("qs")
local equal = require("lib/equal-e2b63a6")

-- case 1: a string, an empty string, and an array
local t = qs.parse("a=a&b=&c=1&c=2")

assert(equal(t.a, {"a"}))
assert(equal(t.b, {""}))
assert(equal(t.c, {"1", "2"}))

-- case 2: make sure we can parse what we built 
local dict = {
	foo = {"foo"},
	bar = {"bar"},
	baz = {""},
	arr = {1, 2, 3},
}

local t = qs.parse(qs.build(dict))

assert(equal(t.foo, {"foo"}))
assert(equal(t.bar, {"bar"}))
assert(equal(t.baz, {""}))
assert(equal(t.arr, {"1", "2", "3"}))

print("All tests passed.")

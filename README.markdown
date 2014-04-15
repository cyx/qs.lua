# querystring.lua

Simple library to pasre / build querystrings.

## usage

```lua
local querystring = require("querystring")

-- case 1: a string, an empty string, and an array
local t = querystring.parse("a=a&b=&c=1&c=2")

assert(t.a == "a")
assert(t.b == "")
assert(t.c[1] == "1")
assert(t.c[2] == "2")

-- case 2: make sure we can parse what we built 
local dict = {
	foo = "foo",
	bar = "bar",
	baz = "",
	arr = {1, 2, 3},
}

local t = querystring.parse(querystring.build(dict))

assert(t.foo == "foo")
assert(t.bar == "bar")
assert(t.baz == "")
assert(t.arr[1] == "1")
assert(t.arr[2] == "2")
assert(t.arr[3] == "3")
```

## notes

Supports querystrings as defined in the RFC here:

    http://tools.ietf.org/html/rfc3986#section-3.4

## license

MIT

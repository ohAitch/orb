# Handle Module


```lua
local L = require "lpeg"

local Node = require "node/node"
local u = require "../lib/util"

local m = require "Orbit/morphemes"

local H, h = u.inherit(Node)

function h.matchHandle(line)
    local handlen = L.match(L.C(m.handle), line)
    if handlen then
        return handlen
        
    else
        return ""
        --u.freeze("h.matchHandle fails to match a handle")
    end
end

local function new(Handle, line)
    local handle = setmetatable({}, H)
    handle.id = "handle"
    handle.val = h.matchHandle(line):sub(2, -1)
    return handle
end

return u.export(h, new)
```

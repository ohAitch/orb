 
```lua
local L = require( "lpeg" )

local assert = assert
local string, io = assert( string ), assert( io )
local V = string.sub( assert( _VERSION ), -4 )
local _G = assert( _G )
local error = assert( error )
local pairs = assert( pairs )
local next = assert( next )
local type = assert( type )
local tostring = assert( tostring )
local setmetatable = assert( setmetatable )
local setfenv = setfenv
local getfenv = getfenv
if V == " 5.1" then
  assert( setfenv )
  assert( getfenv )
end
```
```lua
local Node = require "node/node"
local u = require "util"
```
```lua

-- module table
local epnf = {}
  

local function make_ast_node( id, first, t, last, str, metas)
  t.first = first
  t.last  = last
  t.str   = str
  if metas[id] then
    io.write("metatable detected: " .. id .. "\n")
    t = metas[id](t, str)
    assert(t.id == id)
  else
    t.id = id
    setmetatable(t, {__index = Node,
                     __tostring = Node.toString})
    
  end
  assert(t.isNode)
  assert(t.str)
  return t
end


-- some useful/common lpeg patterns
local Cp = L.Cp
local Cc = L.Cc
local Ct = L.Ct
local arg1_str = L.Carg(1)
local arg2_metas = L.Carg(2)


-- setup an environment where you can easily define lpeg grammars
-- with lots of syntax sugar
function epnf.define(func, g, e)
  g = g or {}
  if e == nil then
    e = V == " 5.1" and getfenv(func) or _G
  end
  local suppressed = {}
  local env = {}
  local env_index = {
    START = function(name) g[1] = name end,
    SUPPRESS = function(...)
      suppressed = {}
      for i = 1, select('#', ...) do
        suppressed[select(i, ... )] = true
      end
    end,
  }

  setmetatable(env_index, { __index = e })
  setmetatable(env, {
    __index = env_index,
    __newindex = function( _, name, val )
      if suppressed[ name ] then
        g[ name ] = val
      else
        g[ name ] = (Cc(name) 
              * Cp() 
              * Ct(val)
              * Cp()
              * arg1_str
              * arg2_metas) / make_ast_node
      end
    end
  })
  -- call passed function with custom environment (5.1- and 5.2-style)
  if V == " 5.1" then
    setfenv( func, env )
  end
  func( env )
  assert( g[ 1 ] and g[ g[ 1 ] ], "no start rule defined" )
  return g
end


-- return module table
return epnf
```

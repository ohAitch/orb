



local L = require "lpeg"

local s = require "status" 
local define = require "node/define"






local function new(grammar_template, metas)
    local metas = metas or {}
  if type(grammar_template) == 'function' then
    local grammar = define.define(grammar_template, nil, metas)
    io.write("type of grammar is " .. type(grammar) .. "\n")
    for k,v in pairs(grammar) do
      io.write("  " .. tostring(k) .. "  " .. tostring(v) .. "\n")
    end
    return function(str)
            return L.match(grammar, str, 1, str) -- other 
         end
  else
    s:halt("no way to build grammar out of " .. type(template))
  end
end



return new

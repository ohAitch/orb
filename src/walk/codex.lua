











local s = require "core/status" ()
s.verbose = true
local Dir  = require "walk/directory"
local File = require "walk/file"
local Path = require "walk/path"
local Deck = require "walk/deck"




local Codex = {}
Codex.__index = Codex
local __Codices = {} -- One codex per directory










function Codex.spin(codex)
   codex.orb:spin()
end












local function isACodex(dir, codex)
   local isCo = false
   local orbDir, srcDir, libDir, srcLibDir = nil, nil, nil, nil
   codex.root = dir
   dir:getsubdirs()
   for i, sub in ipairs(dir.subdirs) do
      local name = sub:basename()
      if name == "orb" then
         s:verb("orb: " .. tostring(sub))
         orbDir = sub
         codex.orb = sub
      elseif name == "src" then
         s:verb("src: " .. tostring(sub))
         srcDir = Dir(sub)
         codex.src = sub
         srcDir:getsubdirs()
         for j, subsub in ipairs(sub.subdirs) do
            local subname = subsub:basename()
            if subname == "lib" then
               s:verb("src/lib: " .. tostring(subsub))
               subLibDir = subsub
            end
         end
          --]]
      elseif name == "lib" then
         s:verb("lib: " .. tostring(sub))
         libDir = sub
         codex.lib = sub
      end
   end
   if orbDir and srcDir and libDir and subLibDir then
      -- check equality of /lib and /src/lib
      codex.codex = true
   end
   return codex
end



local function new(dir)
   if type(dir) == "string" then
      dir = Dir(dir)
   end
   if __Codices[dir] then
      return __Codices[dir]
   end
   local codex = setmetatable({}, Codex)
   codex = isACodex(dir, codex)
   if codex.orb then
      codex.orb = Deck(codex, codex.orb)
   end
   codex.docs = {}
   codex.srcs = {}
   return codex
end




Codex.idEst = new
return new

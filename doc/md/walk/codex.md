# Codex

Now that we have some abstractions over the parts of a Codex,
let's write a class that's singlehandedly responsible for them.

```lua
local s = require "core/status" ()
s.verbose = true
local Dir  = require "walk/directory"
local File = require "walk/file"
local Path = require "walk/path"
local Deck = require "walk/deck"
```
```lua
local Codex = {}
Codex.__index = Codex
local __Codices = {} -- One codex per directory
```
## Codex.caseOrb(codex)

  This loads information about an Orb directory, including all of its
subdirectories, into the Codex.


It does **not** read the Orb files, which is done lazily, it makes Files
from them and organizes them for later operations.


It's not even clear that this should be a method, might be better as
a local function or just part of the constructor.


```lua
function Codex.caseOrb(codex)
   local orb = codex.orbDir
   assert(orb.idEst == Dir, "orb directory not a directory")
   local orbDeck = Deck(codex, orb)
   return codex
end
```
### isACodex

  Used in our constructor to determine to what degree the local
directory fits the Codex format.  If it meets all the [critera](httk://)
then ``codex.codex`` is set to ``true``.


Any partial matches are added to the Codex as they are found.

```lua
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
```
```lua
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
      local orbDeck = Deck(codex, codex.orb)
   end
   return codex
end
```
```lua
Codex.idEst = new
return new
```
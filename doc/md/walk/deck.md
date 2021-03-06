# Deck


A Deck is the bridge-level abstraction of a directory.


From the ``orb`` perspective, this is specialized on orb files and
directories. I'll then adapt it for weaving and sorcery, once those
become more sophisticated than raw string concatenation.

## Instance fields.

I want to design this interace deliberately so that it supports what I'm
doing rather than getting in the way.


Decks have sub decks, if any, in the array portion of their table.


Files are kept in the ``deck.dir`` object, where they belong.


A deck has a pointer to its codex at ``deck.codex``, and must be created
by one.


Docs go into the ``docs`` map. Currently both in the codex and the
particular deck, keyed by full path name.


Sorcery goes into the ``srcs`` map following the same logic.


A Doc which has ``{basename}.org``, that is, the basename of the deck,
will be added to ``deck.eponym``.  If there is a ``.deck`` file in the
directory, this becomes ``dec.dotDeck``.

```lua
local s   = require "status" ()
s.verbose = false
s.chatty  = true

local c   = require "core/color"
local cAlert = c.color.alert

local Dir = require "walk/directory"
local Doc = require "Orbit/doc"
local Node = require "Node"
```
```lua
local Deck = {}
Deck.__index = Deck
local __Decks = {}
```
```lua
-- ignore a few critters that can show up
local decIgnore = {".DS_Store", ".git", ".orbback"}

local function ignore(file)
   local willIgnore = false
   local basename = file:basename()
   for _, str in ipairs(decIgnore) do
      willIgnore = willIgnore or basename == str
   end
   return willIgnore
end
```
## spin(deck)

If we're going to be lazy, this is where we should do it!


Right now, we're going to load all Docs into memory, willy nilly.

```lua
local function spin(deck)
   local err = {}
   local dir = deck.dir
   local codex = deck.codex
   for _, subdeck in ipairs(deck) do
      spin(subdeck)
   end
   local files = dir:getfiles()
   for _, file in ipairs(files) do
      if not ignore(file) then
         local doc = Doc(file:read())
         if doc.id and doc.id == "doc" then
            deck.docs[file.path.str] = doc
            codex.docs[file.path.str] = doc
         else
            s:complain("no doc",
                       tostring(file) .. " doesn't generate a doc")
         end
      end
   end
   return deck, err
end

Deck.spin = spin
```
## case(deck)

  Casing is what we call gathering information about a deck, its subdecks,
and associated files.  ``case`` will also pull the ``.deck`` file into memory,
parse it into a Doc, and attach that at ``deck.dotDeck``.


Casing a deck will cause its subdecks to be cased also, recursively. This is
where we will add inode comparison to keep from following cyclic references,
since it's what draws directory attributes out of the filesystem into memory.


After casing a Deck is ready to be [spun](httk://).

```lua
local new

function Deck.case(deck)
   s:verb("dir: " .. tostring(deck.dir))
   local dir = deck.dir
   local codex = deck.codex
   local basename = dir:basename()
   assert(dir.idEst == Dir, "dir not a directory")
   local codexRoot = codex.root:basename()
   s:verb("root: " .. tostring(codex.root) .. " base: " ..tostring(codexRoot))
   local subdirs = dir:getsubdirs()
   s:verb("  " .. "# subdirs: " .. #subdirs)
   for i, sub in ipairs(subdirs) do
      s:verb("  - " .. sub.path.str)
      deck[i] = new(codex, sub)
   end
   local files = dir:getfiles()
   s:verb("  " .. "# files: " .. #files)
   for i, file in ipairs(files) do
      if not ignore(file) then
         local name = file:basename()
         if name == ".deck" then
            s:ver()
            deck.dotDeck = file
         elseif #file:extension() > 1 then
            name = string.sub(name, 1, - #file:extension() - 1)
         end
         if name == basename then
            s:verb("  ~ " .. name)
            deck.eponym = file
         end
      end
   end

   s:verb("#deck is : " .. #deck)
   return codex
end
```
### __tostring

```lua
function Deck.__tostring(deck)
   return deck.dir.path.str
end
```
```lua
new = function (codex, dir)
   if type(dir) == "string" then
      dir = Dir(dir)
   end
   if __Decks[dir] then
      return __Decks[dir]
   end
   local deck = setmetatable({}, Deck)
   deck.dir = dir
   deck.codex = codex
   deck.docs  = {}
   deck.srcs  = {}
   Deck.case(deck)
   return deck
end
```
```lua
Deck.idEst = new
return new
```

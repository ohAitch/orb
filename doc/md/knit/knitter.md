# Knitter Module
   A knitter is the actor responsible for knitting together our source
 code.  They are defined by language, which is to say that the unit of 
 action is not a runtime or document, knitters will expand to be 
 responsible for an arbitrary number of these.

 The bootstrap knitter does what a knitter will do by default:  go through
 =.../org/*/*.gm= and generate =.../src/*.*.lang= for all code blocks in
 =#lang=. 

 It must do so through an interface which will let it grow up.

### An Aside
   This is the last verb in Grimoire which needs to be written in pure
 Lua.  Huzzah! Typing -- all the time is tiresome and I didn't want to
 patch Sublime just for that.

 I do intend to design a 
 [syntax highligher for Sublime](etc/Grimoire.sublime_syntax), just
 a simple minimum-viable that will make editing the Lua inside =grym= 
 pleasant while I polish up femto. 

 
## Design
   =grym invert= is an isolated module.  It's a shim; if better tools 
 succeeds, we'll stop using it within the Arc in fairly short order.

 =grym knit=, by contrast, is part of the core system.  Software tends
 to stick around, and a Grimoire is a language-as-in-human-language
 sort of project.  An advantage we intend to offer over Org is a 
 nice Unix-flavor toolkit for munging flat files from your choice of
 editor.
 
 =knit= methods receive a parsed document, not a string.  The Knitter 
 modules generates language specific transformers for various Nodes,
 and the Knit module uses them when called for. 

```lua
local u = require "lib/util"

local K, k = u.inherit()
```
## knit method
   This is where it all comes together.

 We're still bootstrapping.  The only language is lua, we don't know 
 what hashtags are yet, and we go in simple linear order.
 
 - knitter :  the knit module. That is, K, rather than a given k in 
              K.langs.
 - doc     :  a Doc.

 - #return : the knit file as a string.


```lua
function K.knit(knitter, doc)
    local codeblocks = doc:select("codeblock")
    local phrase = ""
    for _, cb in ipairs(codeblocks) do
        phrase = phrase .. cb.val .. "\n" -- a little extra ws for now

    end

    return phrase
end

local function new(Knitter, lang)
    local knitter = setmetatable({}, K)
    knitter.lang = lang or "lua"
    return knitter
end

return u.export(k, new)
```
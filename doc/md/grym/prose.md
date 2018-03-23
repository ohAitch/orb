# Prose module
  Here we need a proper recursive parser.

```lua
local L = require "lpeg"
local u = require "util"
local m = require "grym/morphemes"

local epnf = require "peg/epnf"
```
## Bookend parsing
  We need to generate parsers to match sequences of single characters, so
that *bold*, **bold**, ***bold*** etc all work correctly.

Bookends are a fun construct borrowed from the [[LPEG manual][httk://]]]]
model for Lua long strings.  The GGG/Pegylator form of a bookend construct
is 

```peg
    bookend = "`":a !"`":a pattern  "`":a
```
The =lpeg= engine doesn't model this directly but it's possible to provide
it.  We only need the subset of this where =a= is unique, that is, =pattern=
does not contain =bookend= at any level of expansion. 

GGG being a specification format needn't respect this limitation.  Orb
does so by design.  It is a simple consquence of the sort of markup we are
using; there is no need to parse ***bold **inside bold** still bold*** twice,
and this generalizes to all text styles. 

We do have to wire them up so that we don't cross the streams.  Sans macros.
By hand. 

```lua
local function equal_strings(s, i, a, b)
   -- Returns true if a and b are equal.
   -- s and i are not used, provided because expected by Cb.
   return a == b
end

local function bookends(sigil)
   -- Returns a pair of patterns, _open and _close,
   -- which will match a brace of sigil.
   -- sigil must be a string. 
   local _open = Cg(C(P(sigil)^1), sigil .. "_init")
   local _close =  Cmt(C(P(sigil)^1) * Cb(sigil .. "_init"), equal_strings)
   return _open, _close
end

local bold_open, bold_close     =  bookends("*")
local italic_open, italic_close =  bookends("/")
local under_open, under_close   =  bookends("_")
local strike_open, strike_close =  bookends("-")
local lit_open, lit_close       =  bookends("=")
```
### Link or Raw
  The prose parser will be a proper recursive grammar.  This calls for some
enhancements to epnf to allow assignment of Node metatables to matched spans.

I've been sloppy with the node constructor interface and will need to go through
the whole =grym= directory and fix it into a consistent state.  At some point.

Links give me a chance to design that interface to fit grammatically. For now,
we're going to handroll another Link class, and write a simple either-or parser
over prose strings that finds links and puts the rest in a =raw= class, which
shouldn't need an intermediate Node class. 

This Link class needs to fit the constructor semantics of =epeg.Csp=.













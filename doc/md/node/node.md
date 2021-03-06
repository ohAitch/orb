# Node


  Time to stabilize this class once and for all. 

### includes

```lua
local s = require "status"
local dot = require "node/dot"
```
## Node metatable

  The Node metatable is the root table for any Node.  I'm planning to make
an intermediate class/table called Root that is in common for any instance
Node.  All Root absolutely has to contain is =str=. 

```lua

local N = {}
N.__index = N
N.isNode = true
```
## Fields

   - id :  A string naming the Node. 
           This is identical to the name of the pattern that recognizes
           or captures it.


   - line_first :  Always -1.
   - line_last  :  Always -1. 

```lua
N.line_first = -1
N.line_last  = -1
```

It occurs to me we could lazily calculate these using the [line iterator](httk://).


## Methods


### Visualizers

This gives us a nice, tree-shaped printout of an entire Node.


We're less disciplined than we should be about up-assigning this to
inherited Node classes. 

```lua
function N.toString(node, depth)
   local depth = depth or 0
   local phrase = ""
   phrase = ("  "):rep(depth) .. "id: " .. node.id .. ",  "
      .. "first: " .. node.first .. ", last: " .. node.last .. "\n"
   if node[1] then
    for _,v in ipairs(node) do
      if(v.isNode) then
        phrase = phrase .. N.toString(v, depth + 1)
      end
    end
  end 
   return phrase
end
```
```lua
function N.dotLabel(node)
  return node.id
end

function N.toMarkdown(node)
  if not node[1] then
    return string.sub(node.str, node.first, node.last)
  else
    s:halt("no toMarkdown for " .. node.id)
  end
end

function N.dot(node)
  return dot.dot(node)
end

function N.toValue(node)
  if node.__VALUE then
    return node.__VALUE
  end
  if node.str then
    return node.str:sub(node.first,node.last)
  else
    s:halt("no str on node " .. node.id)
  end
end

```
### Iterators

These yield a new element per call in the usual Lua =for= pattern. 


#### N.walkDeep

Depth-first iterator. 

```lua
function N.walkDeep(node)
    local function traverse(ast)
        if not ast.isNode then return nil end

        for _, v in ipairs(ast) do
            if type(v) == 'table' and v.isNode then
              traverse(v)
            end
        end
        coroutine.yield(ast)
    end

    return coroutine.wrap(function() traverse(node) end)
end
```
#### N.walk

Breadth-first iterator.  This is the default. 

```lua
function N.walk(node)
  local function traverse(ast)
    if not ast.isNode then return nil end

    coroutine.yield(ast)
    for _, v in ipairs(ast) do
      if type(v) == 'table' and v.isNode then
        traverse(v)
      end
    end
  end

  return coroutine.wrap(function() traverse(node) end)
end

```
#### N.select(node, pred)

  Takes the Node and walks it, yielding the Nodes which match the predicate.
=pred= is either a string, which matches to =id=, or a function, which takes
a Node and returns true or false on some premise. 

```lua
function N.select(node, pred)
   local function qualifies(node, pred)
      if type(pred) == 'string' then
         if type(node) == 'table' 
          and node.id and node.id == pred then
            return true
         else
            return false
         end
      elseif type(pred) == 'function' then
         return pred(node)
      else
         s:halt("cannot select on predicate of type " .. type(pred))
      end
   end

   local function traverse(ast)
      -- depth first
      if qualifies(ast, pred) then
         coroutine.yield(ast)
      end
      if ast.isNode then
         for _, v in ipairs(ast) do
            traverse(v)
         end
      end
   end

   return coroutine.wrap(function() traverse(node) end)
end
```
#### N.tokens(node)

  Iterator returning all 'captured' values as strings.

```lua
function N.tokens(node)
  local function traverse(ast)
    for node in N.walk(ast) do
      if not node[1] then
        coroutine.yield(node:toValue())
      end
    end
  end

  return coroutine.wrap(function() traverse(node) end)
end  
```
### Collectors

These return an array of all results. 


- [ ] #todo  Add a Forest class to provide the iterator interface for
             the return arrays of this class.

```lua
function N.gather(node, pred)
  local gathered = {}
  for ast in N.select(node, pred) do
    gathered[#gathered + 1] = ast
  end
  
  return gathered
end
```
## Node Instances

  To be a Node, currently, indexed elements of the Array portion must also be 
Nodes. 


I'm mostly convinced that indexed elements can also be strings, and that 
this is the form leaf nodes should take.  Currently, they have a 'val' field
and no children, which we should replace with a child string at [1].


This gives us a lighter way to handle the circumstance where we have, say,
a list, =(foo bar baz)=. We currently either need a "left-per" or "pal"
Node class to hold the =(=, or we would have to skip it entirely.


Quipu can't lose any information from the string, so they have to include
whitespace.  We're not limited in the same way and can reconstruct less 
semantically crucial parts of a document using the span and the original 
string, since we're not /currently/ editing our strings once they're
entered in.


Nodes are meant to be broadly compatible with everything we intend to
do with abstract syntax trees.  The more I think about this the better
it strikes me as an approach. 


### Fields

  There are invariant fields a Node is also expected to have, they are:
 
  - first :  Index into =str= which begins the span.
  - last  :  Index into =str= which ends the span.


In principle, we want the Node to be localized. We could include a 
reference to the whole =str= and derive substrings lazily.


If we included the full span as a substring on each Node, we'd end up
with a lot of spans, and wouldn't use most of them. Even slicing a piece
out is costly if we're not going to use it. 


So our constructor for a Node class takes (Constructor, node, str) as 
the standard interface.  If a module needs a non-standard constructor,
as our Section and Block modules currently take an array of lines, that
will need to be provided as the second return from the module. 


This will allow for the kind of multi-pass recursive-descent that I'm
aiming for. 


#### line tracking (optional)

It may be wise to always track lines, in which case we will include:


  - line_first :  The line at which the match begins
  - line_last  :  The line at which the match ends


This is, at least, a frequent enough pattern that the metatable should return
a negative number if these aren't assigned. 


- [ ] #todo decide if line tracking is in fact optional


### Other fields

  The way the Grammar class will work: each =V"patt"= can have a metatable.
These are passed in as the second parameter during construction, with the key
the same name as the rule. 


If a pattern doesn't have a metatable, it's given a Node class and consists of
only the above fields, plus an array representing any subrules. 


If it does, the metatable will have a =__call= method, which expects two
parameters, itself, and the node, which will include the span. 


This will require reattunement of basically every class in the =/grym= folder,
but let's build the Prose parse first.  I do want the whole shebang in a single
grammar eventually.


The intention is to allow multiple grammars to coexist peacefully. Currently
the parser is handrolled and we have special case values for everything.
The idea is to stabilize this, so that multi-pass parsing works but in a
standard way where the Node constructor is a consistent interface. 


In the meantime we have things like


- lines :  If this exists, there's a collection of lines which need to be
           joined with =\n= to reconstruct the actual span.


           We want to do this the other way, and use the span itself for the
           inner parse. 

```lua
return N
```

# Doc module

 Represents a Document, which is generally the same as a file, at first.


 A document contains an array of blocks.


 At some point documents can also contain documents, this is not
 currently supported.


## Fields
«quote endquote»


 In addition to the standard Node fields, a doc has:


 - latest: The current block.  This will be in doc[#doc] but may
           be several layers deep.
 - lastOf: An array containing references to the last block of a
           given level.


```lua
local u = require "lib/util"

local Node = require "lib/node/node"
local Section = require "Orbit/section"
local own = require "Orbit/own"
```
### Metatable for Docs.

```lua
local D = setmetatable({}, { __index = Node })
D.id = "doc"

D.__tostring = function (doc)
    local phrase = ""
    for _,v in ipairs(doc) do
        local repr = tostring(v)
        if repr ~= "" and repr ~= "\n" then
            phrase = phrase .. repr .. "\n"
        end
    end

    return phrase
end


D.__index = D

D.own = own

function D.dotLabel(doc)
    return "doc - " .. tostring(doc.linum)
end

function D.toMarkdown(doc)
    local phrase = ""
    for _, node in ipairs(doc) do
        if node.toMarkdown then
            phrase = phrase .. node:toMarkdown()
        else
            u.freeze("no toMarkdown method for " .. node.id)
        end
    end
    return phrase
end
```
### Doc Constructor


```lua
local d = {}


function D.parentOf(doc, level)
    local i = level - 1
    local parent = nil
    while i >= 0 do
        parent = doc.lastOf[i]
        if parent then
            return parent
        else
            i = i - 1
        end
    end

    return doc
end
```

 This function looks at document level and places the block
 accordingly.


 - doc : the document
 - block : block to be appended


 returns: the document


```lua
function D.addSection(doc, section, linum, finish)
    assert(section.id == "section", "type of putative section is " .. section.id)
    assert(section.first, "no first in section at line " .. tostring(linum))
    assert(type(finish) == "number", "finish is of type " .. type(finish))
    if not doc.latest then
        doc[1] =  section
    else
        if linum > 0 then
            doc.latest.line_last = linum - 1
            doc.latest.last = finish
        end
        local atLevel = doc.latest.level
        if atLevel < section.level then
            -- add the section under the latest section
            doc.latest:addSection(section, linum, finish)
        else
            local parent = doc:parentOf(section.level)
            if parent.id == "doc" then
                if section.level == 1 and doc.latest.level == 1 then
                    doc[#doc + 1] = section
                else
                    doc.latest:addSection(section, linum, finish)
                end
            else
                parent:addSection(section, linum, finish)
            end
        end
    end
    doc.latest = section
    doc.lastOf[section.level] = section
    return doc
end


function D.addLine(doc, line, linum, finish)
    if doc.latest then
        doc.latest:addLine(line)
        doc.latest.last = finish
    else
        -- a virtual zero block
        doc[1] = Section(0, linum, 1, #line, doc.str)
        doc.latest = doc[1]
        doc.latest:addLine(line)
        doc.latest.last = finish
    end

    return doc
end
```

 Creates a Doc Node.

 @Doc: this is d @return: a Doc representing this data.```lua
local function new(Doc, str)
    local doc = setmetatable({}, D)
    doc.str = str
    doc.first = 1
    doc.last = #str
    doc.latest = nil
    doc.lines = {}
    doc.lastOf = {}
    -- for now lets set root to 'false'
    doc.root = false
    return doc:own(str)
end

setmetatable(D, Node)

d["__call"] = new

return setmetatable({}, d)
```

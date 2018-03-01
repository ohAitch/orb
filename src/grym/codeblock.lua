-- * Code Block Module
--
--
--   Code blocks are the motivating object for Grimoire.  Perforce they
-- will do a lot of the heavy lifting.
--
-- From the compiler's perspective, Code, Structure, and Prose are the
-- three basic genres of Grimmorian text.  In this implementation,
-- you may think of Code as a clade diverged early from both Structure
-- and Prose, with some later convergence toward the former. 
-- 
-- Specifically, Structure and Prose will actually inherit from Block, and
-- Code block, name notwithstanding, merely imitates some behaviours.
-- 
--
-- ** Fields
--
--
--   Codeblock inherits from Node directly, and is born with these 
-- additional fields:
--
-- - level  :  The number of !s, which is the number of / needed to close
--             the block.
-- - header :  The line after # and at least one !.
-- - lines  :  Array containing the lines of code.  Header not included.
-- - line_first :  The first (header) line of the block. 
-- - line_last  :  The closing line of the block. Note that code blocks also
--                 collect blank lines and may have a clinging tag. 
-- 
-- To be added:
-- - [ ] lang : 

local L = require "lpeg"

local Node = require "peg/node"

local m = require "grym/morphemes"

local CB = setmetatable({}, Node)

CB.__index = CB

CB.__tostring = function() return "codeblock" end

local cb = {}

-- Matches a code block header line.
--
-- - #args
--   - str :  The string to match against.
-- 
-- - #return 3
--   - boolean :  For header match
--   - number  :  Level of header
--   - string  :  Header stripped of left whitespace and tars
--
function cb.matchHead(str)
    if str ~= "" and L.match(m.codestart, str) then
        local trimmed = str:sub(L.match(m.WS * m.hax, str))
        local level = L.match(m.zaps, trimmed) - 1
        local bareline = trimmed:sub(L.match(m.zaps, trimmed))
        return true, level, bareline
    else 
        return false, 0, ""
    end
end

-- Matches a code block footer line.
--
-- - #args
--   - str   :  The string to match against.
--   - level :  Required level for a match.
-- 
-- - #return 3
--   - boolean :  For footer match
--   - number  :  Level of header
--   - string  :  Header stripped of left whitespace and tars
--
function cb.matchFoot(str)
    if str ~= "" and L.match(m.codefinish, str) then
        local trimmed = str:sub(L.match(m.WS * m.hax, str))
        local level = L.match(m.fass, trimmed) - 1
        local bareline = trimmed:sub(L.match(m.fass, trimmed))
        return true, level, bareline
    else 
        return false, 0, ""
    end
end

-- Constructor

local function new(Codeblock, level, headline, linum)
    local codeblock = setmetatable({}, CB)
    codeblock.level = level
    codeblock.header = headline
    codeblock.line_first = linum
    codeblock.lines = {}

    return codeblock
end


cb.__call = new
cb.__index = cb

return setmetatable({}, cb)
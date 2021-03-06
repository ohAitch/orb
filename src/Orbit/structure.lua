











local Node = require "node/node"
local u = require "../lib/util"

local Hashline = require "Orbit/hashline"
local Handleline = require "Orbit/handleline"





local S, s = u.inherit(Node)

function S.dotLabel(structure)
    -- This is a shim and will break.
    if structure.temp_id then 
        return structure.temp_id
    else
        return "structure"
    end
end

function S.toMarkdown(structure)
    if structure[1] and structure[1].toMarkdown then
        return structure[1]:toMarkdown()
    else
        return structure.__VALUE
    end
end

function S.toValue(structure)
    return structure.__VALUE
end






local function new(Structure, line, line_id, str)
    local structure = setmetatable({}, S)
    structure.__VALUE = line
    structure.id = "structure"
    if line_id == "hashline" then
        structure[1] = Hashline(line)
    elseif line_id == "handleline" then
        structure[1] = Handleline(line)
    end
    structure.str = str
    return structure
end


return u.export(s, new)

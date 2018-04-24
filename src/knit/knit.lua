





local L = require "lpeg"

local s = require "status" ()
local a = require "ansi"
s.chatty = true
s.verbose = false

local pl_file = require "pl.file"
local pl_dir = require "pl.dir"
local pl_path = require "pl.path"
local getfiles = pl_dir.getfiles
local getdirectories = pl_dir.getdirectories
local makepath = pl_dir.makepath
local extension = pl_path.extension
local dirname = pl_path.dirname
local basename = pl_path.basename
local read = pl_file.read
local write = pl_file.write
local delete = pl_file.delete
local isdir = pl_path.isdir


local knitter = require "knit/knitter"

local Dir = require "walk/directory"
local Path = require "walk/path"
local File = require "walk/File"

local walk = require "walk" -- factoring this out
local strHas = walk.strHas
local endsWith = walk.endsWith
local subLastFor = walk.subLastFor
local writeOnChange = walk.writeOnChange

local Doc = require "Orbit/doc"
local Path = require "walk/path"












local function knitDeck(deck)
    local dir = deck.dir
    local codex = deck.codex
    local orbDir = codex.orb
    local srcDir = codex.src
    for i, sub in ipairs(deck) do
        knitDeck(sub)
    end
    for name, doc in pairs(deck.docs) do
        local knitted, ext = knitter:knit(doc)
        if knitted then
            -- add to srcs
            local srcpath = Path(name):subFor(orbDir, srcDir, ext)
            s:verb("knitted: " .. name)
            s:verb("into:    " .. tostring(srcpath))
            deck.srcs[srcpath] = knitted
            codex.srcs[srcpath] = knitted
        end

    end
    return srcs
end

local function writeOnChange(out_file, newest)
    newest = tostring(newest)
    out_file = tostring(out_file)
    local current = read(tostring(out_file))
    -- If the text has changed, write it
    if newest ~= current then
        s:chat(a.green("  - " .. tostring(out_file)))
        write(out_file, newest)
        return true
    -- If the new text is blank, delete the old file
    elseif current ~= "" and newest == "" then
        s:chat(a.red("  - " .. tostring(out_file)))
        delete(out_file)
        return false
    else
    -- Otherwise do nothing

        return nil
    end
end

local function knitCodex(codex)
    local orb = codex.orb
    local src = codex.src
    s:chat("knitting orb directory: " .. tostring(orb))
    s:chat("into src directory: " .. tostring(src))
    knitDeck(orb, src)
    for name, src in pairs(codex.srcs) do
        writeOnChange(name, src)
    end
end
knitter.knitCodex = knitCodex


return knitter

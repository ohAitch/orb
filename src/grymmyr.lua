--[[

Grimoire Grammar

]]

local lpeg = require "lpeg"
local epeg = require "peg/epeg"
local epnf = require "peg/epnf"

local match = lpeg.match -- match a pattern against a string
local P = lpeg.P -- match a string literally
local S = lpeg.S  -- match anything in a set
local R = epeg.R  -- match anything in a range
local B = lpeg.B
local C = lpeg.C  -- captures a match
local Csp = epeg.Csp -- captures start and end position of match
local Ct = lpeg.Ct -- a table with all captures from the pattern
local V = lpeg.V -- create a variable within a grammar

local letter = R"AZ" + R"az" 
local valid_sym = letter + P"-"  
local digit = R"09"
local sym = valid_sym + digit
local WS = P' ' + P',' + P'\09' -- Not accurate, refine (needs Unicode spaces)
local NL = P"\n"

local _grym_fn = function ()
	local function grymmyr (_ENV)
		START "grym"

		SUPPRESS ("structure")

		local prose_word = (valid_sym^1 + digit^1)^1
		local prose_span = (prose_word + WS^1)^1

		local NEOL = NL + -P(1)

		grym      = V"section"^1 --* EOF("Failed to reach end of file")

		section   = (V"header" * V"block"^0) + V"block"^1

		structure = V"blank_line" -- list, table, json, comment...

		header     = V"lead_ws" * V"lead_tar" * V"prose_line"
		lead_ws = Csp(WS^0)
		lead_tar   = Csp(P"*"^-6 * P" ")
		prose_line = Csp(prose_span * NEOL)

		block = (V"structure"^1 + V"prose"^1)^1 * #V"block_end"

		prose = (V"structured" + V"unstructured")^1
		unstructured = Csp((prose_span * NEOL)^1 + prose_span)
		structured = V"bold"
		bold = Csp(P"*" * prose_span * P"*")

		block_end = V"blank_line"^1 + -P(1) + #V"header"
		
		blank_line = Csp(WS^0 * NL)

	end
	return grymmyr
end

return epnf.define(_grym_fn(), nil, false)
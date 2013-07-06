-- Insult store
local lg = love.graphics

local Store = {}
Store.__index = Store

-- New player object
function Store:new()
	local obj = { 
		-- Store's inventory of insults, upgrades, etc.
		insults = {},
	}

	-- Load the insult data
	files = love.filesystem.enumerate('insults')
	for id,file in pairs(files) do
		if string.sub(file, -string.len("insult")) == "insult" then
			local current_insult = 0
			for line in love.filesystem.lines('insults/' .. file) do
				-- Ignore comments
				if string.sub(line, 1, 2) == "--" then
					-- Nothing
				elseif string.sub(line, 1, 5) == "name:" then
					current_insult = current_insult + 1		
					obj.insults[current_insult] = {}
					obj.insults[current_insult].text = {}
					obj.insults[current_insult].name = string.sub(file, 6)
				elseif string.sub(line, 1, 6) == "level:" then
					obj.insults[current_insult].level = string.sub(file, 7)
				elseif string.sub(line, 1, 7) == "damage:" then
					obj.insults[current_insult].damage = string.sub(file, 8)
				elseif string.sub(line, 1, 5) == "cost:" then
					obj.insults[current_insult].damage = string.sub(file, 6)
				elseif string.sub(line, 1, 6) == "combo:" then
					obj.insults[current_insult].damage = string.sub(file, 7)
				elseif string.sub(line, 1, 5) == "rate:" then
					obj.insults[current_insult].damage = string.sub(file, 6)
				elseif string.sub(line, 1, 9) == "critical:" then
					obj.insults[current_insult].critical = string.sub(file, 10)
				else
					local level = tonumber(string.sub(line, 1, 1))
					
					-- It's some text for an insult
					if not (level == nil) and level > 0 and level <= 9 then
						if obj.insults[current_insult].text[level] == nil then
							obj.insults[current_insult].text[level] = {}
						end
						table.insert(obj.insults[current_insult].text[level], string.sub(line, 3))
					else
						print ("Malformed insult line: " .. line)
					end
				end
			end
		end
	end

	return setmetatable(obj, Store)
end

-- Store drawing function
function Store:draw()
	-- Draw the inventory screen
end

return Store

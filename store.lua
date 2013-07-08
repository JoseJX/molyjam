-- Insult store
local Button = require 'button'
local lg = love.graphics

local Store = {}
Store.__index = Store

local UI_line_height = 30
local UI_CB_width = 50
local UI_TX_width = 250
local UI_UP_width = 100
local UI_scroll_width = 30
local UI_line_separator = 10
local UI_caller_offset = 30 + 2*UI_line_separator
-- local UI_player_offset = 100

-- New player object
function Store:new(window)
	local obj = { 
		-- Store's inventory of insults, upgrades, etc.
		insults = {},
		-- Scroll distance
		scroll = 0,
		-- Render window
		window = window,
		-- Current # of insults checked
		checked = 0,
		max_checked = 3,
		min_level = 1,
	}

	-- Update the render window
	obj.window[1] = obj.window[1] + UI_line_separator/2
	obj.window[2] = obj.window[2] + UI_caller_offset
	obj.window[3] = UI_CB_width + UI_TX_width + UI_UP_width + UI_scroll_width
	obj.window[4] = (UI_line_height + UI_line_separator)*3

	-- Load the insult data
	local current_insult = 0
	files = love.filesystem.enumerate('insults')
	for id,file in pairs(files) do
		if string.sub(file, -string.len("insult")) == "insult" then
			local insult_upgrade = 0
			current_insult = current_insult + 1		
			obj.insults[current_insult] = { current_level = 1, max_level = 1, upgrades = {}, min_level = 1 }
			local upgrade = nil
			for line in love.filesystem.lines('insults/' .. file) do
				-- Ignore comments
				if string.sub(line, 1, 2) == "--" then
					-- Nothing
				elseif string.sub(line, 1, 5) == "name:" then
					-- Store the previous upgrade
					if not(upgrade == nil) then
						obj.insults[current_insult].upgrades[insult_upgrade] = upgrade	
						upgrade = nil
					end
					upgrade = {}
					upgrade.text = {}
					upgrade.name = string.sub(line, 6)
				elseif string.sub(line, 1, 10) == "min_level:" then
					obj.insults[current_insult].min_level = tonumber(string.sub(line, 11))
				elseif string.sub(line, 1, 12) == "description:" then
					upgrade.descripton = string.sub(line, 13)
				elseif string.sub(line, 1, 6) == "level:" then
					upgrade.level = string.sub(line, 7)
					insult_upgrade = tonumber(string.sub(line,7))
				elseif string.sub(line, 1, 7) == "damage:" then
					upgrade.damage = string.sub(line, 8)
				elseif string.sub(line, 1, 5) == "cost:" then
					upgrade.cost = string.sub(line, 6)
				elseif string.sub(line, 1, 6) == "combo:" then
					upgrade.combo = string.sub(line, 7)
				elseif string.sub(line, 1, 5) == "rate:" then
					upgrade.rate = string.sub(line, 6)
				elseif string.sub(line, 1, 9) == "critical:" then
					upgrade.critical = string.sub(line, 10)
				else
					-- Make sure all upgrades are stored
					if not(upgrade == nil) then
						obj.insults[current_insult].upgrades[insult_upgrade] = upgrade	
						upgrade = nil
					end

					-- Get the upgrade level this statement is for
					local level = tonumber(string.sub(line, 1, 1))
					
					-- It's some text for an insult
					if not (level == nil) and level > 0 and level <= 9 then
						table.insert(obj.insults[current_insult].upgrades[level].text, string.sub(line, 3))
					else
						print ("Malformed insult line: " .. line)
					end
				end
			end
			-- Update the max # of levels
			obj.insults[current_insult].max_level = table.getn(obj.insults[current_insult].upgrades)
			-- Add in the buttons for this insult
			local x_val = obj.window[1] + UI_CB_width + UI_TX_width
			local y_val = obj.window[2] + (UI_line_height + UI_line_separator) * (current_insult - 1)
			if obj.insults[current_insult].min_level == 1 then
				obj.insults[current_insult].checkbox = Button:new("X", obj.window[1], y_val, UI_CB_width, UI_line_height,'center')
			else
				obj.insults[current_insult].checkbox = Button:new("", obj.window[1], y_val, UI_CB_width, UI_line_height,'center')
			end
			obj.insults[current_insult].title = Button:new(obj.insults[current_insult].upgrades[obj.insults[current_insult].current_level].name, obj.window[1] + UI_CB_width, y_val, UI_TX_width, UI_line_height, 'left')
			obj.insults[current_insult].title.fill_type = 'partial'
			obj.insults[current_insult].upgrade = Button:new("Upgrade", x_val, y_val, UI_UP_width, UI_line_height,'center')
		end
	end
			
	return setmetatable(obj, Store)
end

-- Update the store view
function Store:update(dt, level, bp)
	for id, insult in ipairs(self.insults) do
		if level >= insult.min_level then
			insult.title.text = insult.upgrades[insult.current_level].name
			insult.title.enabled = true
			insult.checkbox.enabled = true
		else
			insult.title.text = "Minimum level required: " .. insult.min_level
			insult.title.enabled = false
			insult.checkbox.enabled = false
		end

		-- FIXME - replace 3 with actual #
		if insult.current_level < 3 then
			if level >= (tonumber(insult.upgrades[insult.current_level + 1].level) * tonumber(insult.min_level)) then
				insult.upgrade.enabled = true
				insult.title.fill_amt = bp / (insult.upgrades[insult.current_level + 1].cost * (insult.current_level + 1))
				if insult.title.fill_amt > 1 then
					insult.title.fill_amt = 1
				end
			else
				insult.upgrade.enabled = false
			end
		elseif insult.current_level == 3 then
			insult.upgrade.enabled = false
			insult.upgrade.text = "Complete"
		else
			insult.upgrade.enabled = false
		end
	end
end

-- Check the buttons for contact
-- Returns the cost in bp spent
function Store:check(x, y, button, player_bp)
	for id, insult in ipairs(self.insults) do
		-- Equip button
		if insult.checkbox:check(x, y - self.scroll, button) then
			if button == false and self.checked < self.max_checked then
				if insult.checkbox.text == "X" then
					insult.checkbox.text = ""	
				else
					insult.checkbox.text = "X"	
				end
			end
		end

		-- Upgrade button
		if insult.upgrade:check(x, y - self.scroll, button) then
			if button == false and insult.title.fill_amt == 1 then	
				insult.current_level = insult.current_level + 1		
				return (insult.upgrades[insult.current_level].cost * insult.current_level)
			end
		end
	end
	return 0
end

-- Store drawing function
-- Render all of the UI and translate to show the appropriate part
function Store:draw(level)
	-- Push the current state
	lg.push()

	-- Scroll the list
	lg.translate(0, -self.scroll)

	lg.setColor(255,255,255,255)
	-- For each insult type, display three things:
	for id, insult in ipairs(self.insults) do 
		-- Checkbox (Enables the insult in your collection)
		insult.checkbox:draw()
		-- Draw the name of the insult
		insult.title:draw()
		-- Draw the upgrade button
		insult.upgrade:draw()
	end
	
	-- Up/Down scrollers
	-- self.up_button:draw()
	-- self.down_button:draw()
	
	-- Restore the current state
	lg.pop()
end

return Store

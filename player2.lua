-- Player data
local lg = love.graphics
local Store = require 'store'
local Bar = require 'bar'
local Button = require 'button'

local Player = {}
Player.__index = Player

local UI_line_separator = 10
local UI_button_width = 300
local UI_button_height = 30

-- New player object
function Player:new(window)
	local obj = { 
		-- Render window
		window = window,
		-- Name of the player playing for HS List
		name = "Player",
		-- Score
		score = 0,
		-- Lives left
		phones_left = 5,
		-- Player stats
		int = 0,
		dex = 0,
		im = 0,
		-- Player's experience
		xp = 0,
		level = 1,
		next_level = 100,
		-- Player's patience
		patience = 100,
		-- Player's brain points
		bp = 0,
		-- Player's inventory
		inventory = {},

		-- Insult Store
		store = {},

		-- Insult buttons for the battle UI
		insult_buttons = {}
	}
	-- Create some random stats
	obj.int = math.random(1,10)
	obj.dex = math.random(1,10)
	obj.im = math.random(1,10)

	-- Instance the store
	obj.store = Store:new(window)

	-- Instance the insult buttons
	for i = 1,3 do 
		local i_x = obj.window[1] + UI_line_separator/2
		local i_y = obj.window[2] + UI_caller_offset + (UI_line_height + UI_line_separator) * (i - 1)

		obj.insult_buttons[i] = Button:new("", i_x, i_y, UI_button_width, UI_button_height)
	end
	
	return setmetatable(obj, Player)
end

-- Update the player's stats
function Player:update(dt)
	-- Increment the player's brain points
	self.bp = self.bp + (dt * self.im)
end

-- Check if an insult can be cast
function Player:check_insult(id)
	local level = self.inventory[id].current_level

	if self.inventory[id].upgrades[level].cost > self.bp then
		return false
	end
	return true
end

-- Attack! - Returns damage amount
function Player:attack(id) 
	local insult = self.inventory[id].upgrades[self.inventory[id].current_level]
	
	local combo = math.random(1, insult.combo)		
	local damage = self.inventory[id].upgrades[level].damage
	local critical = math.random()
	if critical < self.dex/100 then
		critical = insult.critical
	else
		critical = 1
	end
	local rate = math.random()
	if rate < self.int/10 * self.rate then
		rate = 1
	else
		rate = 0
	end

	local total = rate * (combo * (damage * critical))
	return total	
end

-- Add experience
function Player:addXP(patience)
	self.xp = self.xp + patience * 1/self.level	
	if self.xp >= self.next_level then
		self.level = self.level + 1
		self.xp = self.xp - self.next_level
		return true
	end
	return false
end

-- Check buttons
function Player:check(x, y, button, call_state)
	-- Store state
	if call_state == "Hiding" then
		self.store:check(x, y, button)
		-- Get the checked insults from the store
		self.inventory = {}
		for id, insult in ipairs(self.store.insults) do
			if insult.checkbox.text == "X" then
				table.insert(self.inventory, insult)
				self.insult_buttons[id].text = insult.upgrades[insult.current_level].name
			end
		end
	-- Battle state
	else
		for id, insult in ipairs(self.insult_buttons) do
			-- Insult cast?
			if self.insult_buttons[id]:check(x, y, button) == true then
				-- Check if the insult is castable with the current state	
				
			end
		end
	end
end

-- Player drawing function
function Player:draw(call_state)
	-------------------------------------------------------------
	-- Draw the inventory screen
	-- Upgrades, insult selection, etc.
	-- The upgrade screen only shows when you're hiding the phone
	-------------------------------------------------------------
	if call_state == "Hiding" then
		self.store:draw(self.level)
	---------------------
	-- Battle Menu
	---------------------
	else
		for button_id, button in ipairs(self.insult_buttons) do
			button:draw()
		end
--
--		-- Display the current brain points and bar
--		self.brain_bar:draw()
	end	
	
	----------------
	-- Current stats
	----------------
	local sb_x = 650
	local sb_y = 190
	local sb_w = 150
	local sb_h = 95
	local line_x = sb_x + 10
	local line_h = 15
	local line = sb_y + 10
	-- Draw the box surrounding the stats
	lg.setColor(0,0,0,255)
	lg.rectangle('fill', sb_x, sb_y, sb_w, sb_h)	
	lg.setColor(255,255,255,255)
	lg.rectangle('fill', sb_x + 5, sb_y + 5, sb_w - 10 , sb_h - 10)
	lg.setColor(0,0,0,255)
	-- Current Level and XP
	lg.print("Level: ".. self.level, line_x, line)
	line = line + line_h
	lg.print("Next level: " .. self.xp .. "/" .. self.next_level, line_x, line)
	-- Intelligence
	line = line + line_h
	lg.print("Intelligence: ".. self.int, line_x, line)
	-- Mental Dexterity
	line = line + line_h
	lg.print("Mental Dexterity: " .. self.dex, line_x, line)
	-- Imagination
	line = line + line_h
	lg.print("Imagination: " .. self.im, line_x, line)

end

return Player

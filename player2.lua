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
local UI_caller_offset = 30 + 2*UI_line_separator
local UI_line_height = 30
local int_multiplier = 5

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
		max_bp = 0,
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

	-- Calculate the max BP
	obj.max_bp = obj.int * int_multiplier + obj.dex + obj.im

	-- Instance the store
	obj.store = Store:new(window)

	-- Instance the insult buttons
	for i = 1,3 do 
		local i_x = obj.window[1] + UI_line_separator/2
		local i_y = obj.window[2] + (UI_line_height + UI_line_separator) * (i - 1)
		obj.insult_buttons[i] = Button:new("No insult selected...", i_x, i_y, UI_button_width, UI_button_height, 'left')
		obj.insult_buttons[i].fill_type = 'partial'
		obj.insult_buttons[i].fill_amt = 0
	end
	
	return setmetatable(obj, Player)
end

-- Update the player's stats
function Player:update(dt, call_state)
	if call_state == "Talking" then
		-- Increment the player's brain points
		self.bp = self.bp + (dt * self.im)
		if self.bp > self.max_bp then
			self.bp = self.max_bp
		end

		for i = 1,3 do
			self.insult_buttons[i].enabled = true
			if not (self.inventory[i] == nil) then
				self.insult_buttons[i].fill_amt = self.insult_buttons[i].fill_amt + (dt * self.im) / (self.inventory[i].upgrades[self.inventory[i].current_level].cost)
				if self.insult_buttons[i].fill_amt > 1 then
					self.insult_buttons[i].fill_amt = 1
				end
			end
		end
	elseif call_state == "OnHold" then
		for i = 1,3 do
			self.insult_buttons[i].enabled = false
		end
		self.bp = self.bp - (dt * self.im)/2
	elseif call_state == "Missed" or call_state == "Insulted" then
		for i = 1,3 do
			self.insult_buttons[i].enabled = false
		end
	elseif call_state == "Hiding" then
		self.bp = 0
	end
end

-- Check if an insult can be cast
function Player:check_insult(id)
	local level = self.inventory[id].current_level

	if tonumber(self.inventory[id].upgrades[level].cost) > tonumber(self.bp) then
		return false
	end
	return true
end

-- Attack! - Returns damage amount
function Player:attack(id) 
	local insult = self.inventory[id].upgrades[self.inventory[id].current_level]
	
	local combo = math.random(1, insult.combo)		
	local damage = insult.damage
	local critical = math.random()
	if critical < self.dex/100 then
		critical = insult.critical
	else
		critical = 1
	end
	local rate = math.random()
	if rate < self.int/10 * insult.rate then
		rate = 1
	else
		rate = 0
	end

	local total = rate * (combo * (damage * critical))

	-- Take away the casting cost
	self.bp = self.bp - insult.cost

	return total	
end

-- Add experience
function Player:addXP(patience)
	self.xp = self.xp + patience * 1/self.level	
	if self.xp >= self.next_level then
		self.level = self.level + 1
		self.xp = self.xp - self.next_level

		-- Calculate the max BP
		self.max_bp = self.int * int_multiplier + self.dex + self.im

		return true
	end
	return false
end

-- Check buttons
function Player:check(x, y, button, call_state)
	if button == true then
		return 0
	end

	-- Store state
	if call_state == "Hiding" then
		self.store:check(x, y, button)
		-- Get the checked insults from the store
		self.inventory = {}
		local button_id = 1
		for id, insult in ipairs(self.store.insults) do
			if insult.checkbox.text == "X" then
				table.insert(self.inventory, insult)
				self.insult_buttons[button_id].text = insult.upgrades[insult.current_level].name
				button_id = button_id + 1
			end
		end
		if button_id <= self.store.max_checked then
			for i = button_id, self.store.max_checked do 
				self.insult_buttons[i].text = "No insult selected..."	
				self.inventory[i] = nil
			end
		end
	-- Battle state
	else
		for id, insult in ipairs(self.insult_buttons) do
			-- Insult cast?
			if self.insult_buttons[id]:check(x, y, button) == true then
				-- Check if the insult is castable with the current state	
				if self:check_insult(id) == true then
					self.insult_buttons[id].fill_amt = 0
					return id
				end
			end
		end
	end
	return 0
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

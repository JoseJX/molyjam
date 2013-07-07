-- Player data
local lg = love.graphics
local Store = require 'store'

local Player = {}
Player.__index = Player

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
		next_level = 1000,
		-- Player's brain points
		bp = 0,
		-- Player's inventory
		inventory = {},

		-- Insult Store
		store = {},

		-- Buttons for the player UI

	}
	-- Create some random stats
	obj.int = math.random(1,10)
	obj.dex = math.random(1,10)
	obj.im = math.random(1,10)

	-- Instance the store
	obj.store = Store:new(window)
	return setmetatable(obj, Player)
end

-- Update the player's stats
function Player:update(dt)

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
			end
		end
	-- Battle state
	else

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
		-- Get the checked insults from the store
		


--		for button_id, button in ipairs(self.insult_buttons) do
--			button:draw()
--		end
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

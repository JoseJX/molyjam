-- Player data
local lg = love.graphics

local Player = {}
Player.__index = Player

-- New player object
function Player:new()
	local obj = { 
		-- Name of the player playing for HS List
		name = "Player",
		-- Score
		score = 0,
		-- Lives left
		phones_left = 5,
		-- Player stats
		player_xp = 0,
		player_int = 0,
		player_dex = 0,
		player_im = 0,
		-- Player's inventory of insults
		inventory = {},
		-- Equipped inventory slots
		equipped = {},
		-- Text currently being drawn for the player
		player_text = "",
	}
	return setmetatable(obj, Player)
end

-- Update the player's stats
function Player:update(dt)

end

-- Player drawing function
function Player:draw(phone_state)
	----------------------------------------
	-- Draw the speech bubble for the player
	----------------------------------------
	if phone_state == "Talking" then
		speech_y = self.win_y + self.win_h - speech_h

		-- Temporarily adjust the scissor so we can draw the speech bubble
		lg.setScissor(self.win_x, self.win_y, self.win_w, window_height - self.win_y)

		lg.setColor(255,255,255,255)
		lg.rectangle('fill', speech_x, speech_y, speech_w, speech_h)
		lg.setColor(0,0,0,255)
		lg.rectangle('line', speech_x, speech_y, speech_w, speech_h)

		-- Draw the spike
		bs_x1 = speech_x + speech_w/2 - caller_box_border/2
		bs_y1 = speech_y + speech_h - 3
		bs_x2 = bs_x1 + caller_box_border
		bs_y2 = bs_y1
		bs_x3 = bs_x1 + caller_box_border/2
		bs_y3 = bs_y1 + (window_height - win_height) / 4
		lg.setColor(255,255,255,255)
		lg.polygon('fill', bs_x1, bs_y1, bs_x2, bs_y2, bs_x3, bs_y3)
		lg.setColor(0,0,0,255)
		lg.line(bs_x1, bs_y1, bs_x3, bs_y3)
		lg.line(bs_x2, bs_y2, bs_x3, bs_y3)
	
		-- Reset the scissor
		lg.setScissor(self.win_x, self.win_y, self.win_w, self.win_h)

		-- Draw the text
		lg.setColor(0,0,0,255)
		lg.printf(self.player_text, speech_x, speech_y + caller_box_border, speech_w, 'center')
	end

	------------------------------------------------
	-- Draw the inventory screen
	-- Upgrades, insult selection, etc.
	------------------------------------------------
	if false then
		-- For each insult type, display three things:
		-- for
		--	-- Checkbox (Enables the insult in your collection)
		--	self.checks[i]:draw()
		--	-- Insult name
		--	lg.printf()
		--	-- Upgrade button
		--	self.upgrade_button[i]:draw()
		-- end
		
		-- Up/Down scrollers
		-- self.up_button:draw()
		-- self.down_button:draw()
		
	else
		---------------------
		-- Battle Menu
		---------------------
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
	-- Current Level and XP
	-- lg.printf()
	-- Intellegence
	-- lg.printf()	
	-- Mental Dexterity
	-- lg.printf()
	-- Imagination
	-- lg.printf()
end

return Player

-- Text generation
local lg = love.graphics

local Text = {}
Text.__index = Text

local babble_rate = 5

-- New text creation object
function Text:new()
	local obj = { 
		-- Current text to be rendered
		caller_text = "",
		player_text = "",
		
		-- Text generator data
		pieces = {},
		pauses = {},
		responses = {},

		-- Current Caller's fixed text responses
		caller = {
			intro = "",
			win = "",
			loss = "",
			waiting = "",
			hold = "",
		},

		-- Time since last babble change
		babble_dt = 0,
		babble_last = 'player',
		-- Time between babble changes, between 1 second and this value
		babble_rate = babble_rate,
	}
	
	-- Load the babble
	for line in love.filesystem.lines('scripts/conversation_pieces') do
		table.insert(obj.pieces, line)
	end
	for line in love.filesystem.lines('scripts/conversation_pauses') do
		table.insert(obj.pauses, line)
	end
	for line in love.filesystem.lines('scripts/conversation_responses') do
		table.insert(obj.responses, line)
	end
	return setmetatable(obj, Text)
end

-- Is it time to update the text?
function Text:update(dt, phone_state)
	if phone_state == "Talking" then
		self.babble_dt = self.babble_dt + dt
		if self.babble_dt > math.random(2, self.babble_rate) then
			if self.babble_last == "player" then
				self:updateText("caller", "babble")	
				self.babble_last = "caller"
			else
				self:updateText("player", "babble")	
				self.babble_last = "player"
			end
			self.babble_dt = 0
		end
	elseif phone_state == "OnHold" then
		self:updateText("caller", "hold")
	end
end

-- Change the current caller's fixed responses
function Text:switchCaller(data)
	self.caller = data
end

-- Text drawing function
function Text:draw()
	-- Draw the inventory screen
	
	-- Draw the battle screen
end

-- Update the caller text
function Text:updateText(who, state)
	if who == "caller" then
		if state == "babble" then
			-- Find out how many words to render
			local words = math.random(5,7)
			self.caller_text = self:getConversation(words, true)
		else
			self.caller_text = self.caller[state]
		end
	else
		if(state == "babble") then
			-- Find out how many words to render
			local words = math.random(5,7)
			self.player_text = self:getConversation(words, false)
		else
			self.player_text = "Thank you for calling the Technoob line, how can I help you?"
		end
	end
end

-- Generate a new bit of conversation
function Text:getConversation(words, response)
	local r = math.random(#self.pauses)
	local c = self.pauses[r]
	local blah_rate = 0.75
	local last_conversation = { r, 0 }
	
	for i = 1,words do
		-- More blahs
		if math.random() < blah_rate then
			r = math.random(#self.pauses)
			while (r == last_conversation[1]) do
				r = math.random(#self.pauses)
			end
			c = c .. " " .. self.pauses[r]
			last_conversation[1] = r
		-- Pick a random conversation part
		else
			if (response == true) then
				r = math.random(#self.responses)
				while (r == last_conversation[2]) do
					r = math.random(#self.responses)
				end

				c = c .. " " .. self.responses[r]
				last_conversation[2] = r
			else
				r = math.random(#self.pieces)
				while (r == last_conversation[2]) do
					r = math.random(#self.pieces)
				end

				c = c .. " " .. self.pieces[r]
				last_conversation[2] = r
			end
		end
	end

	-- Upper case the first letter and add punctuation
	r = math.random()
	if r < 0.33 then
		c = c:sub(1,1):upper() .. c:sub(2) .. "."	
	elseif r < 0.66 then
		c = c:sub(1,1):upper() .. c:sub(2) .. "?"
	else
		c = c:sub(1,1):upper() .. c:sub(2) .. "!"
	end

	return c
end

-- Draw the text specified
function Text:draw(who, x, y, width)
	-- Draw the text
	lg.setColor(0,0,0,255)
	if who == "caller" then
		lg.printf(self.caller_text, x, y, width, 'center')
	else
		lg.printf(self.player_text, x, y, width, 'center')
	end
end

return Text

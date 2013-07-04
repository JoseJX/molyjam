-- Implements the caller minigame
local Button = require 'button'
local Bar = require 'bar'
local Utils = require 'utils'

local Caller = {}
Caller.__index = Caller

local lg = love.graphics
local caller_box_border = 10
local caller_box_width = 125 + caller_box_border
local caller_box_height = 200 + caller_box_border

function Caller:new()
	local obj = { 
		-- Which caller is calling?
		caller_id = 1,
		-- Caller image data
		images = {},
		-- Caller script data
		callers = {},
		-- Current text the caller is saying
		caller_text = "",
		-- Current text the player is saying
		player_text = "",	
		-- Problem list
		problems = {},	
		-- Color text for fake conversations
		pieces = {},
		pauses = {},
		responses = {},
		last_conversation = { 0, 0 },
		-- Buttons for interacting with the user
		buttons = {},
		-- Phone state (talking or not)
		phone_state = "talking",
	}

	-- Load all of the caller data
	files = love.filesystem.enumerate('scripts') 
	for id,file in pairs(files) do
		if string.sub(file, -string.len("script")) == "script" then
			for line in love.filesystem.lines('scripts/' .. file) do

			end
			-- Load the caller image
			local cpic_name = string.sub(file, 1, -(string.len("script")+1))
			table.insert(obj.images, lg.newImage("graphics/" .. cpic_name .. "png"))
		end
	end

	-- Load the problem list
	for line in love.filesystem.lines('scripts/problems') do
		table.insert(obj.problems, line) 
	end

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

	obj = setmetatable(obj, Caller)

	-- Initialize the player text
	obj:updateText(false, "player")
	obj:updateText(false, "caller")


	-- FIXME
	-- obj.text[1] = {}
	-- table.insert(obj.text[1], "I'm so happy! I've been singing ALLLLLL day!")
	-- table.insert(obj.text[1], "It goes like this: 'LOVE LOVE LOVE LOVE LALALOVE!'")
	
	-- Make some buttons
	-- for i=1,4 do
	-- 	table.insert(buttons, Button:new("Button #" .. i, window_width / 2 + UI_divider_width * 2, UI_bar_height + UI_button_start_height + (UI_button_spacer * (i-1)), UI_button_width, UI_button_height))	
	-- end

	-- Set the button text
	-- buttons[1]:setText("Do you even lift?")
	-- buttons[2]:setText("That's how your mother likes it!")
	-- buttons[3]:setText("I know you are, but what am I?")
	-- buttons[4]:setText("How appropriate, you fight like a cow!")
	return obj
end

-- Update the caller text
function Caller:updateText(initial, who)
	if who == "caller" then
		if(initial == true) then
			-- FIXME
			self.caller_text = "Hi."
		else
			-- Find out how many words to render
			local words = math.random(5,7)
			self.caller_text = self:getConversation(words, true)
		end
	else
		if(initial == true) then
			-- FIXME
			self.player_text = "Hi."
		else
			-- Find out how many words to render
			local words = math.random(5,7)
			self.player_text = self:getConversation(words, false)
		end
	end
end

-- Generate a new bit of conversation
function Caller:getConversation(words, response)
	local r = math.random(#self.pauses)
	self.last_conversation[1] = r
	local c = self.pauses[r]
	local blah_rate = 0.75
	
	for i = 1,words do
		-- More blahs
		if math.random() < blah_rate then
			r = math.random(#self.pauses)
			while (r == self.last_conversation[1]) do
				r = math.random(#self.pauses)
			end
			c = c .. " " .. self.pauses[r]
			self.last_conversation[1] = r
		-- Pick a random conversation part
		else
			if (response == true) then
				r = math.random(#self.responses)
				while (r == self.last_conversation[2]) do
					r = math.random(#self.responses)
				end

				c = c .. " " .. self.responses[r]
				self.last_conversation[2] = r
			else
				r = math.random(#self.pieces)
				while (r == self.last_conversation[2]) do
					r = math.random(#self.pieces)
				end

				c = c .. " " .. self.pieces[r]
				self.last_conversation[2] = r
			end
		end
	end
	-- Reset the conversation
	self.last_conversation = { 0, 0 }

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

-- Draw the caller image
function Caller:draw()
	-- Get the draw area
	local win_x, win_y, win_width, win_height = lg.getScissor()
	local box_x = win_x + (win_width - (caller_box_width + caller_box_border/2))
	local box_y = win_y + (win_height - caller_box_height)/2
	
	--------------------
	-- Draw the portrait
	--------------------
	-- Draw the bounding box
	lg.setColor(255,128,0,255)
	lg.rectangle('fill', box_x, box_y, caller_box_width, caller_box_height)
	lg.setColor(255,255,255,255)
	lg.rectangle('fill', box_x + caller_box_border/2, box_y + caller_box_border/2, caller_box_width - caller_box_border, caller_box_height - caller_box_border)
	-- Draw the character
	lg.draw(self.images[self.caller_id], box_x + caller_box_border/2, box_y + caller_box_border/2)

	-------------------------
	-- Draw the speech bubble
	-------------------------
	local speech_x = win_x + caller_box_border/2
	local speech_y = win_y + caller_box_border/2
	local speech_w = win_width - caller_box_border
	local speech_h = 30

	lg.setColor(255,255,255,255)
	lg.rectangle('fill', speech_x, speech_y, speech_w, speech_h)
	lg.setColor(0,0,0,255)
	lg.rectangle('line', speech_x, speech_y, speech_w, speech_h)

	-- Draw the bubble spike
	local bs_x1 = box_x + caller_box_width/2 + caller_box_border/2
	local bs_y1 = speech_y + speech_h - 3
	local bs_x2 = bs_x1 + caller_box_border
	local bs_y2 = bs_y1
	local bs_x3 = box_x + caller_box_width/2
	local bs_y3 = box_y + caller_box_border
	lg.setColor(255,255,255,255)
	lg.polygon('fill', bs_x1, bs_y1, bs_x2, bs_y2, bs_x3, bs_y3)
	lg.setColor(0,0,0,255)
	lg.line(bs_x1, bs_y1, bs_x3, bs_y3)
	lg.line(bs_x2, bs_y2, bs_x3, bs_y3)

	-- Draw the text
	lg.setColor(0,0,0,255)
	lg.print(self.caller_text, speech_x + caller_box_border/2, speech_y + caller_box_border/2)
	
	----------------------------------------
	-- Draw the speech bubble for the player
	----------------------------------------
	if self.phone_state == "talking" then
		speech_y = win_y + win_height - speech_h

		-- Temporarily adjust the scissor so we can draw the speech bubble
		lg.setScissor(win_x, win_y, win_width, window_height - win_y)

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
		lg.setScissor(win_x, win_y, win_width, win_height)

		-- Draw the text
		lg.setColor(0,0,0,255)
		lg.print(self.player_text, speech_x + caller_box_border/2, speech_y + caller_box_border/2)
	end

	---------------------
	-- Buttons
	---------------------
	--for button_id, button in ipairs(buttons) do
	--	button:draw()
	--end
	
end

return Caller

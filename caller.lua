-- Implements the caller minigame
local Button = require 'button'
local Bar = require 'bar'
local Utils = require 'utils'

local Caller = {}
Caller.__index = Caller

local lg = love.graphics

function Caller:new()
	local obj = { 
		-- Image data
		images = {},
		-- Caller data
		callers = {},
		-- Which caller is calling?
		caller_id = 1,
		-- Problem list
		problems = {},	
		-- Color text for fake conversations
		pieces = {},
		pauses = {},
		responses = {},
		last_conversation = { 0, 0},
		-- Buttons for interacting with the user
		buttons = {},
	}

	-- Load all of the caller data
	files = love.filesystem.enumerate('scripts') 
	for id,file in pairs(files) do
		if string.sub(file, -string.len("script")) == "script" then
			for line in love.filesystem.lines('scripts/' .. file) do

				print(line)
			end
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
			
	--table.insert(obj.images, lg.newImage("bear.png"))

	-- Load all of the text for each caller
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
	return setmetatable(obj, Caller)
end

-- FIXME: Add caller logic
-- For now, just swap text
function Caller:update(dt)
	self.next_text = self.next_text + 1
	if(self.next_text > 2) then
		self.next_text = 1
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
	c = c:sub(1,1):upper() .. c:sub(2) .. "."	

	return c
end

-- Draw the caller image
function Caller:draw(x, y)
	x = 1280 - 160
	y = 20
	-- Draw the bounding box
	lg.setColor(255,128,0,255)
	lg.rectangle('fill', x, y, 160, 248)
	lg.setColor(255,255,255,255)
	lg.rectangle('fill', x+5, y+5, 150, 238)
	-- lg.draw(self.images[self.caller_id], x + 5, y + 4)
	
	-- Flavor text 
	--lg.setColor(255,255,255,255)
	--lg.print(c:getText(), window_width/2 + UI_divider_width * 2, UI_bar_height + 10)
	-- Buttons
	--for button_id, button in ipairs(buttons) do
	--	button:draw()
	--end
	
end

return Caller

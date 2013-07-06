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
local button_width = 70
local button_height = 30
local babble_rate = 5

function Caller:new(window, caller_rate)
	local obj = { 
		-- Window position and size
		win_x = window[1],
		win_y = window[2],
		win_w = window[3],
		win_h = window[4],
		-- Which caller is calling?
		-- If 0, no active caller
		caller_id = 0,
		-- Caller image data
		caller_images = {},
		-- Caller script data
		callers = {},
		-- Current text the caller is saying
		caller_text = "",
		-- Current text the player is saying
		player_text = "",	
		-- Color text for fake conversations
		pieces = {},
		pauses = {},
		responses = {},
		-- Insults
		insults = {},
		-- Buttons for interacting with the user
		battle_buttons = {},
		inventory_buttons = {},
		-- Inventory
		inventory = {},
		items = {},
		-- Caller patience bar
		caller_bar = nil,
		-- Player points
		player_thinkpoints = nil,
		-- Rate that new callers call in 
		caller_rate = caller_rate,
		-- Caller answer buttons, located over the portrait
		answer_button = nil,
		refuse_button = nil,
		-- Time since last babble change
		babble_dt = 0,
		babble_last = 'player',
		-- Time between babble changes, between 1 second and this value
		babble_rate = babble_rate,
		-- Phones remaining
		phones_left = 5,
	}

	-- Load all of the caller data
	local files = love.filesystem.enumerate('scripts') 
	for id,file in pairs(files) do
		if string.sub(file, -string.len("script")) == "script" then
			local c = {
				text = {}
			}
			for line in love.filesystem.lines('scripts/' .. file) do
				-- Ignore comments
				if string.sub(line, 1, 2) == "--" then
					-- Nothing
				elseif string.sub(line, 1, 5) == "name:" then
					c.name = string.sub(line, 6)
				elseif string.sub(line, 1, 9) == "patience:" then
					c.patience = string.sub(line, 10)
				elseif string.sub(line, 1, 6) == "intro:" then
					c.intro = string.sub(line, 7) 
				elseif string.sub(line, 1, 4) == "win:" then
					c.win = string.sub(line, 5)
				elseif string.sub(line, 1, 5) == "lost:" then
					c.lost = string.sub(line, 6)
				elseif string.sub(line, 1, 8) == "waiting:" then
					c.waiting = string.sub(line, 9)
				elseif string.sub(line, 1, 5) == "hold:" then
					c.hold = string.sub(line, 6)
				-- All other lines, based on the level of response
				else
					local level = tonumber(string.sub(line, 1, 1))
					
					-- It's some text for an insult
					if not (level == nil) and level > 0 and level <= 9 then
						if c.text[level] == nil then
							c.text[level] = {}
						end
						table.insert(c.text[level], string.sub(line, 3))
					else
						print("Malformed script line: " .. line)
					end	

				end
			end
			table.insert(obj.callers, c)
			-- Load the caller image
			local cpic_name = string.sub(file, 1, -(string.len("script")+1))
			table.insert(obj.caller_images, lg.newImage("graphics/" .. cpic_name .. "png"))
		end
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

	-- Configure the anser/refuse buttons
	local box_x = obj.win_x + (obj.win_w - (caller_box_width + caller_box_border/2))
	local box_y = obj.win_y + (obj.win_h - caller_box_height)/2
	obj.answer_button = Button:new("Answer", box_x, box_y + caller_box_height, button_width, button_height, 'center')
	obj.refuse_button = Button:new("Refuse", box_x + caller_box_width - button_width, box_y + caller_box_height, button_width, button_height, 'center')
	obj.answer_button.visible = false
	obj.refuse_button.visible = false

	-- Configure the user's patience bar
	obj.caller_bar = Bar:new()
	obj.caller_bar.color = { 200, 40, 0, 255 }
	obj.caller_bar.bg_color = { 40, 255, 0, 255 }

	obj = setmetatable(obj, Caller)
	return obj
end

-- Update the state of the caller
function Caller:update(dt)
	-- If the caller id is 0, we need to pick a new caller
	if self.caller_id == 0 then
		-- We got a new caller
		if(math.random() <= self.caller_rate) then
			-- Create the caller
			self:create()
			-- Turn on the caller answer button
			self.answer_button.visible = true
			self.refuse_button.visible = true
		end
	-- We have a live caller
	else
		if cv.phone_state == "Talking" then
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
		elseif cv.phone_state == "OnHold" then
			self:updateText("caller", "hold")
		elseif cv.phone_state == "Caught" then
			self.answer_button.visible = false
			self.refuse_button.visible = false
		end
	end
end

-- Create a new caller when the user presses answer
function Caller:create()
	-- Set up the new caller
	self.caller_id = math.random(#self.callers)
	self.caller_bar.value = self.callers[self.caller_id].patience
	self.caller_bar.full = self.callers[self.caller_id].patience
	-- Set up the text
	self:updateText("caller", "waiting")
end

-- Check the caller buttons
function Caller:check(x, y, button) 
	-- Check the answer button		
	if cv.phone_state == "Using" and self.answer_button:check(x, y, button) then
		-- We're in game mode!
		if button == false then
			self.answer_button.visible = false
			self.refuse_button.visible = false
			-- Set the mode to talking
			-- Update the text
			self:updateText("player", "intro")
			self:updateText("caller", "intro")
			cv.phone_state = "Talking"
			cv.phone_state = "Talking"
		end
	-- Lame, the player rejected the call
	elseif self.refuse_button:check(x, y, button) then
		self.caller_id = 0
		if button == false then
			self.answer_button.visible = false
			self.refuse_button.visible = false
		end
	end
end

-- Update the caller text
function Caller:updateText(who, state)
	if who == "caller" then
		if(state == "babble") then
			-- Find out how many words to render
			local words = math.random(5,7)
			self.caller_text = self:getConversation(words, true)
		else
			self.caller_text = self.callers[self.caller_id][state]
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
function Caller:getConversation(words, response)
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

-- Draw the caller image
function Caller:draw()
	lg.setScissor(self.win_x, self.win_y, self.win_w, self.win_h)
	lg.setColor(128,128,128,255)
	lg.rectangle('fill', self.win_x, self.win_y, self.win_w, self.win_h)

	local box_x = self.win_x + (self.win_w - (caller_box_width + caller_box_border/2))
	local box_y = self.win_y + (self.win_h - caller_box_height)/2
	
	if self.caller_id > 0 then
		--------------------
		-- Draw the portrait
		--------------------
		-- Draw the bounding box
		lg.setColor(255,128,0,255)
		lg.rectangle('fill', box_x, box_y, caller_box_width, caller_box_height)
		lg.setColor(255,255,255,255)
		lg.rectangle('fill', box_x + caller_box_border/2, box_y + caller_box_border/2, caller_box_width - caller_box_border, caller_box_height - caller_box_border)
		-- Draw the character
		lg.draw(self.caller_images[self.caller_id], box_x + caller_box_border/2, box_y + caller_box_border/2)
		-- Draw the patience bar
		if self.answer_button.visible == false then
			self.caller_bar:draw(box_x, box_y + caller_box_height - 10, caller_box_width, 20)
			lg.setColor(0,0,0,255)
			lg.printf(self.caller_bar.value .. "/" .. self.caller_bar.full .. " Patience", box_x, box_y + caller_box_height - 10, caller_box_width, 'center')
		end
		-- Draw the answer/refuse buttons if needed
		self.answer_button:draw()
		self.refuse_button:draw()

		-------------------------
		-- Draw the speech bubble
		-------------------------
		local speech_x = self.win_x + caller_box_border/2
		local speech_y = self.win_y + caller_box_border/2
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
		lg.printf(self.caller_text, speech_x, speech_y + caller_box_border, speech_w, 'center')
	
		----------------------------------------
		-- Draw the speech bubble for the player
		----------------------------------------
		if cv.phone_state == "Talking" then
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

		---------------------
		-- Battle Menu
		---------------------
--		for button_id, button in ipairs(self.insult_buttons) do
--			button:draw()
--		end
--
--		-- Display the current brain points and bar
--		self.brain_bar:draw()

	------------------------------------------------
	-- Upgrades, insult selection, etc.
	------------------------------------------------
	else
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
	
end

return Caller

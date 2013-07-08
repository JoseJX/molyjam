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
		no_caller = nil,
		-- Caller script data
		callers = {},
		-- Has the call been answered yet?
		caller_answered = false,
		-- Caller patience bar
		caller_bar = nil,
		-- Caller has lost counter
		caller_done = false,	
		caller_lost_ct = 0,
	}

	-- Load all of the caller data
	local files = love.filesystem.enumerate('scripts') 
	for id,file in pairs(files) do
		if string.sub(file, -string.len("script")) == "script" then
			-- New caller instance
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
				elseif string.sub(line, 1, 7) == "missed:" then
					c.missed = string.sub(line, 8)
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

	-- Load the "no caller" image
	obj.no_caller = lg.newImage("graphics/no_caller.png")

	-- Configure the user's patience bar
	obj.caller_bar = Bar:new()
	obj.caller_bar.fgColor = { 0, 128, 256, 255 }
	obj.caller_bar.bgColor =  {255, 128, 0, 255 }
	obj = setmetatable(obj, Caller)
	return obj
end

-- Update the state of the caller
function Caller:update(dt)
	-- FIXME: Cast attacks back at the player...
	
	-- Return the state of the caller
	if tonumber(self.caller_bar.value) <= 0 then
		return true
	end	
	return false
end

-- The caller got attacked
function Caller:gotAttacked(patience)
	self.caller_bar:updateValue(-patience)
	if self.caller_bar.value <= 0 then
		self.caller_bar.value = 0
		self.caller_done = true	
	end
end

-- "Disconnect" caller, and get ready for a new caller
function Caller:disconnect(lost_phones)
	self.caller_id = 0
	caller_answered = false
end

-- Create a new caller instance
function Caller:create()
	-- Set up the new caller
	self.caller_id = math.random(#self.callers)
	self.caller_bar.value = self.callers[self.caller_id].patience
	self.caller_bar.full = self.callers[self.caller_id].patience
	caller_answered = false
end

-- Get the current caller's talk information
function Caller:getText()
	return self.callers[self.caller_id]
end

-- Draw the caller image
function Caller:draw(call_state, text)
	lg.setScissor(self.win_x, self.win_y, self.win_w, self.win_h)

	local box_x = self.win_x + (self.win_w - (caller_box_width + caller_box_border/2))
	local box_y = self.win_y + (self.win_h - caller_box_height)/2

	--------------------
	-- Draw the portrait
	--------------------
	-- Draw the bounding box
	lg.setColor(255,128,0,255)
	lg.rectangle('fill', box_x, box_y, caller_box_width, caller_box_height)
	lg.setColor(255,255,255,255)
	lg.rectangle('fill', box_x + caller_box_border/2, box_y + caller_box_border/2, caller_box_width - caller_box_border, caller_box_height - caller_box_border)
	-- Draw the character
	if self.caller_id > 0 then
		lg.draw(self.caller_images[self.caller_id], box_x + caller_box_border/2, box_y + caller_box_border/2)
	else
		lg.draw(self.no_caller, box_x + caller_box_border/2, box_y + caller_box_border/2)
	end

	-- Draw the patience bar
	if call_state == "OnHold" or call_state == "Talking" or call_state == "Missed" or call_state == "Insulted" then
		lg.setColor(255,255,255,255)
		self.caller_bar:draw(box_x, box_y + caller_box_height - 10, caller_box_width, 20)
		lg.setColor(0,0,0,255)
		lg.printf(self.caller_bar.value .. "/" .. self.caller_bar.full .. " Patience", box_x, box_y + caller_box_height - 5, caller_box_width, 'center')
	end

	-------------------------
	-- Draw the speech bubble
	-------------------------
	local speech_x = self.win_x + caller_box_border/2
	local speech_y = self.win_y + caller_box_border/2
	local speech_w = self.win_w - caller_box_border
	local speech_h = 30
	
	lg.setColor(255,255,255,255)
	lg.rectangle('fill', speech_x, speech_y, speech_w, speech_h)
	lg.setColor(0,0,0,255)
	lg.rectangle('line', speech_x, speech_y, speech_w, speech_h)
	
	if self.caller_id > 0 then
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
		text:draw("caller", speech_x, speech_y + 0.25 * speech_h, speech_w)
	else
		lg.printf("Waiting for call...", speech_x, speech_y + 0.25 * speech_h, speech_w, 'center')
	end
	
	----------------------------------------
	-- Draw the speech bubble for the player
	-- Done here because it's easier...
	----------------------------------------
	if call_state == "Talking" or call_state == "Insulted" or call_state == "Missed" then
		local speech_x = self.win_x + caller_box_border/2
		local speech_y = self.win_y + self.win_h - speech_h
		local speech_w = self.win_w - caller_box_border
		local speech_h = 30

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

		-- Draw the text
		text:draw("player", speech_x, speech_y + 0.25 * speech_h, speech_w)
		
		-- Reset the scissor
		lg.setScissor(self.win_x, self.win_y, self.win_w, self.win_h)
	end
end

return Caller

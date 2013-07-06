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
		-- Caller script data
		callers = {},
		-- Caller patience bar
		caller_bar = nil,
		-- Caller answer buttons, located over the portrait
		answer_button = nil,
		refuse_button = nil,
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

	-- Configure the user's patience bar
	obj.caller_bar = Bar:new()
	obj.caller_bar.color = { 200, 40, 0, 255 }
	obj.caller_bar.bg_color = { 40, 255, 0, 255 }

	obj = setmetatable(obj, Caller)
	return obj
end

-- Update the state of the caller
function Caller:update(dt)
	-- FIXME
end

-- Create a new caller instance
function Caller:create()
	-- Set up the new caller
	self.caller_id = math.random(#self.callers)
	self.caller_bar.value = self.callers[self.caller_id].patience
	self.caller_bar.full = self.callers[self.caller_id].patience
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
	end
end

return Caller

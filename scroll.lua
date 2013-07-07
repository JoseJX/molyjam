-- Draw a scroll bar
-- Buttons for the sides
local Button = require 'button'
local ScrollBar = {}
ScrollBar.__index = ScrollBar

local lg = love.graphics
local UI_button_width = 50
local UI_button_height = 30
local UI_bar_width = 50

function ScrollBar:new(count, x, y, height)
	local obj = { 
		-- Draw location
		x = x,
		y = y,
		height = height,

		-- Position of the bar
		value = 1,
		-- How many ticks does it have?
		count = count 
		-- Foreground color
		fgColor = { 0, 0, 255, 255 },
		-- Background color
		bgColor = { 80, 80, 80, 255 },
		-- Up and down buttons
		up = nil,
		down = nil,

	}
	obj.up = Button:new("-", x, y, UI_button_width, UI_button_height, 'center')
	obj.down = Button:new("+", x, (y + height) - UI_button_height, UI_button_width, UI_button_height, 'center')
	return setmetatable(obj, ScrollBar)
end

-- Update the value
function ScrollBar:setValue(x)
	self.value = x	
end

-- Draw the bar
function ScrollBar:draw(x, y, width, height)
	-- Draw the background rectangle
	lg.setColor(self.bgColor[1], self.bgColor[2], self.bgColor[3], self.bgColor[4])
	lg.rectangle('fill', x, y, width, height)

	-- Draw the filled part
	lg.setColor(self.fgColor[1], self.fgColor[2], self.fgColor[3], self.fgColor[4])
	lg.rectangle('fill', x, y, width * (tonumber(self.value)/tonumber(self.full)), height)
	lg.rectangle('line', x, y, width, height)
	
	-- Draw the two buttons
	obj.up:draw()
	obj.down:draw()
end

return ScrollBar

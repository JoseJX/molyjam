-- Draw a filled in bar
local Bar = {}
Bar.__index = Bar

local lg = love.graphics
local UI_edge_width = 10

function Bar:new()
	local obj = { 
		-- How much of the bar is full?
		value = 0,
		-- How much value == full
		full = 100,
		-- Foreground color
		fgColor = { 0, 0, 255, 255 },
		-- Background color
		bgColor = { 255, 255, 255, 255 },
	}
	return setmetatable(obj, Bar)
end

-- Update the value
function Bar:updateValue(x)
	self.value = self.value + x
end

function Bar:setValue(x)
	self.value = x
end

-- Draw the bar
function Bar:draw(x, y, width, height)
	-- Draw the background rectangle
	lg.setColor(self.bgColor)
	lg.rectangle('fill', x, y - UI_edge_width/2, width, height + UI_edge_width)

	-- Draw the filled part
	lg.setColor(self.fgColor)
	lg.rectangle('fill', x + UI_edge_width/2, y, (width - UI_edge_width) * (tonumber(self.value)/tonumber(self.full)), height)
end

return Bar

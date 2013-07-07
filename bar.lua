-- Draw a filled in bar
local Bar = {}
Bar.__index = Bar

local lg = love.graphics

function Bar:new()
	local obj = { 
		-- How much of the bar is full?
		value = 0,
		-- How much value == full
		full = 100,
		-- Foreground color
		fgColor = { 0, 0, 255, 255 },
		-- Background color
		bgColor = { 80, 80, 80, 255 },
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
	lg.setColor(self.bgColor[1], self.bgColor[2], self.bgColor[3], self.bgColor[4])
	lg.rectangle('fill', x, y, width, height)

	-- Draw the filled part
	lg.setColor(self.fgColor[1], self.fgColor[2], self.fgColor[3], self.fgColor[4])
	lg.rectangle('fill', x, y, width * (tonumber(self.value)/tonumber(self.full)), height)
	lg.rectangle('line', x, y, width, height)
end

return Bar

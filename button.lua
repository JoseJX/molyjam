-- Button UI element
local Button = {}
Button.__index = Button
local lg = love.graphics

function Button:new(text, x_pos, y_pos, width, height)
	local obj = { 
		state = false,
		text = text or "",
		width = width or 100, 
		height = height or 20,
		x = x_pos or 0,
		y = y_pos or 00,
	}

	-- Load all of the caller images
	return setmetatable(obj, Button)
end

-- Set the button text
function Button:setText(t)
	self.text = t
end

-- Check if this button was pressed
function Button:check(x, y, state)
	if (x >= self.x and x < self.x + self.width) and (y >= self.y and y < self.y + self.height) then
		self.state = state
		return true
	end
	return false
end

-- Draw the button
-- FIXME make the text printing less brittle...
function Button:draw()
	-- Draw the outer rim
	lg.setColor(40, 40, 40, 255)
	lg.rectangle('fill', self.x, self.y, self.width, self.height)
	-- If we're pressed, invert the render
	if self.state then
		-- Draw the inside
		lg.setColor(0,0,0,255)
		lg.rectangle('fill', self.x + 5, self.y + 5, self.width - 10, self.height - 10)
		-- Draw the text
		lg.setColor(255,255,255,255)
		lg.print(self.text, self.x + 10, self.y + 10)
	else
		-- Draw the inside
		lg.setColor(255,255,255,255)
		lg.rectangle('fill', self.x + 5, self.y + 5, self.width - 10, self.height - 10)

		-- Draw the text
		lg.setColor(0,0,0,255)
		lg.print(self.text, self.x + 10, self.y + 10)
	end
end

return Button

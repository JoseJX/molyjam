-- Button UI element
local Button = {}
Button.__index = Button
local lg = love.graphics

-- We need absolute x_pos and y_pos so we can check the button presses
function Button:new(text, x_pos, y_pos, width, height, align)
	local obj = { 
		state = false,
		text = text or "",
		width = width or 100, 
		height = height or 20,
		x = x_pos or 0,
		y = y_pos or 0,
		visible = true,
		color = { 0, 0, 0, 255 },
		bg_color = { 255,255,255,255 },
		align = align,
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
	if self.visible == true and (x >= self.x and x < self.x + self.width) and (y >= self.y and y < self.y + self.height) then
		self.state = state
		return true
	end
	return false
end

-- Set the x and y coordinates for this button
function Button:setXY(x, y)
	self.x = x
	self.y = y
end

-- Draw the button
-- NOTE that the x and y are relative to the main coordinate system
-- FIXME make the text printing less brittle...
function Button:draw()
	if self.visible == false then
		return
	end

	-- Draw the outer rim
	lg.setColor(self.color)
	lg.rectangle('fill', self.x, self.y, self.width, self.height)
	-- If we're pressed, invert the render
	if self.state then
		-- Draw the inside
		lg.setColor(self.color)
		lg.rectangle('fill', self.x + 5, self.y + 5, self.width - 10, self.height - 10)
		-- Draw the text
		lg.setColor(self.bg_color)
		lg.printf(self.text, self.x, self.y + 10, self.width, self.align)
	else
		-- Draw the inside
		lg.setColor(self.bg_color)
		lg.rectangle('fill', self.x + 5, self.y + 5, self.width - 10, self.height - 10)
		-- Draw the text
		lg.setColor(self.color)
		lg.printf(self.text, self.x, self.y + 10, self.width, self.align)
	end
end

return Button

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
		fill_color = { 0, 0, 255, 128 },
		enabled = true,
		align = align,
		fill_type = 'full',
		fill_amt = 0,
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
	if self.visible == true and self.enabled == true and (x >= self.x and x < self.x + self.width) and (y >= self.y and y < self.y + self.height) then
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

	-- If we're disabled, grey out the button
	if self.enabled == false then
		self.color[4] = 128
		self.bg_color[4] = 128
		lg.setColor(80,80,80,255)
		lg.rectangle('fill', self.x, self.y, self.width, self.height)
	else
		self.color[4] = 255
		self.bg_color[4] = 255
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
		if self.align == 'center' then
			lg.printf(self.text, self.x, self.y + 10, self.width, self.align)
		else
			lg.printf(self.text, self.x + 10, self.y + 10, self.width, self.align)
		end
		
		if self.fill_type == 'partial' then
			lg.setColor(self.fill_color)
			local fill_amt = self.fill_amt * (self.width - 10)
			lg.rectangle('fill', self.x + 5, self.y + 5, fill_amt, self.height - 10)
		end
	else
		-- Draw the inside
		lg.setColor(self.bg_color)
		lg.rectangle('fill', self.x + 5, self.y + 5, self.width - 10, self.height - 10)
		-- Draw the text
		lg.setColor(self.color)
		if self.align == 'center' then
			lg.printf(self.text, self.x, self.y + 10, self.width, self.align)
		else
			lg.printf(self.text, self.x + 10, self.y + 10, self.width, self.align)
		end
		
		if self.fill_type == 'partial' then
			lg.setColor(self.fill_color)
			local fill_amt = self.fill_amt * (self.width - 10)
			lg.rectangle('fill', self.x + 5, self.y + 5, fill_amt, self.height - 10)
		end
	end
end

return Button

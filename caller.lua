-- Animate the portrait for the caller on the phone in the plane
-- Include the happiness meter for the caller
-- Caller state and other variables assocaited with the caller
local Caller = {}
Caller.__index = Caller

local lg = love.graphics

function Caller:new()
	local obj = { 
		-- Image data
		images = {},
		text = {},
		caller_id = 1,
		width = 150,
		next_text = 1,
	}

	-- Load all of the caller images
	table.insert(obj.images, lg.newImage("bear.png"))

	-- Load all of the text for each caller
	-- FIXME
	obj.text[1] = {}
	table.insert(obj.text[1], "I'm so happy! I've been singing ALLLLLL day!")
	table.insert(obj.text[1], "It goes like this: 'LOVE LOVE LOVE LOVE LALALOVE!'")
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

-- Get the current text
-- FIXME
function Caller:getText()
	return self.text[self.caller_id][self.next_text]
end

-- Draw the caller image
function Caller:draw(x, y)
	-- Draw the bounding box
	lg.setColor(255,128,0,255)
	lg.rectangle('fill', x, y, 160, 248)
	lg.setColor(255,255,255,255)
	lg.rectangle('fill', x+5, y+5, 150, 238)
	lg.draw(self.images[self.caller_id], x + 5, y + 4)
end

return Caller

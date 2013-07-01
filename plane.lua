-- Logic for rendering the plane and parsing the plane player's actions
local Plane = {}
Plane.__index = Plane

local lg = love.graphics

function Plane:new(x_pos, y_pos)
	local obj = { 
		-- Image data
		image = nil,	
		x = x_pos,
		y = y_pos,
		dx = 3,
		dy = 0,
	}

	-- Load the plane sprite
	obj.image = lg.newImage("plane.png")

	return setmetatable(obj, Plane)
end

function Plane:update(dt)
	self.x = self.x + self.dx
end

-- We always draw the plane in the middle of the screen, except when we're near an edge
function Plane:draw(max_altitude, max_distance, screen_height, screen_width)
	-- Draw the plane in the middle of the screen
	lg.setColor(255,255,255,255)
	lg.draw(self.image, screen_width/4, screen_height/2)	
end

return Plane

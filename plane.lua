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
		speed = 5,
		dx = 1,
		dy = 0,
		angle = 0,
	}

	-- Load the plane sprite
	obj.image = lg.newImage("plane.png")

	return setmetatable(obj, Plane)
end

function Plane:update(dt)
	local dx = self.dx
	local dy = self.dy
	-- Update dx/dy
	dx = dx + math.sin(self.angle * (math.pi / 180))
	dy = dy + math.cos(self.angle * (math.pi / 180))

	if(dx > 5) then
		dx = 5
	end
	if(dy > 5) then
		dy = 5
	end
	if(dx < -5) then
		dx = -5;
	end
	if(dy < -5) then
		dy = -5;
	end
	self.dx = dx
	self.dy = dy
	

	-- Update the position
	self.x = self.x + dx
	self.y = self.y + dy
end

-- We always draw the plane in the middle of the screen, except when we're near an edge
function Plane:draw(max_altitude, max_distance, screen_height, screen_width)
	-- Draw the plane in the middle of the screen
	lg.setColor(255,255,255,255)

	-- Save the current coordinate system
	lg.push()

	-- Translate the screen
	lg.translate(screen_width/4, screen_height/2)
	lg.rotate(self.angle)
	lg.translate(-screen_width/4, -screen_height/2)
	lg.draw(self.image, screen_width/4, screen_height/2)	

	-- Restore the coordinate system
	lg.pop()
end

return Plane

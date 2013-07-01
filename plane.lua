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
		dx = 1,
		dy = 0,
		angle = 0,
	}

	-- Load the plane sprite
	obj.image = lg.newImage("plane.png")

	return setmetatable(obj, Plane)
end

-- Forward motion is always 1 unit
function Plane:update(dt)
	local angle = self.angle + 90
	-- Update ax/ay
	local ax = math.sin(math.rad(angle))
	local ay = math.cos(math.rad(angle))

	-- print ("Update Angle: " .. angle)
	-- print (ax, ay)

	-- Update dx/dy
	self.dx = self.dx + ax
	self.dy = self.dy + ay
	-- print (self.dx, self.dy)

	self.dx = math.min(math.max(-5, self.dx), 5)
	self.dy = math.min(math.max(-5, self.dy), 5)

	-- Update the position
	self.x = self.x + self.dx
	self.y = self.y + self.dy

	-- print (self.x, self.y)
end

-- We always draw the plane in the middle of the screen, except when we're near an edge
function Plane:draw(max_altitude, max_distance, screen_height, screen_width)
	-- Draw the plane in the middle of the screen
	lg.setColor(255,255,255,255)

	-- Save the current coordinate system
	lg.push()

	-- Translate the screen
	lg.translate(screen_width/4 + self.image:getWidth()/2, screen_height/2 + self.image:getHeight()/2)
	lg.rotate(math.rad(self.angle))
	lg.translate(-(screen_width/4 + self.image:getWidth()/2), -(screen_height/2 + self.image:getHeight()/2))
	lg.draw(self.image, screen_width/4, screen_height/2)	

	-- Restore the coordinate system
	lg.pop()
end

return Plane

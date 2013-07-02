-- Logic for rendering the plane and parsing the plane player's actions
local Plane = {}
Plane.__index = Plane

local lg = love.graphics

-- Create a new plane object
function Plane:new(x_pos, y_pos, min_altitude, max_altitude)
	local obj = { 
		-- Image data
		image = nil,	
		-- X and Y position for the plane, relative to the center of mass
		x = x_pos,
		y = y_pos,
		-- Angle the plane is currently traveling at (and rotated)
		angle = 0,
		-- Current forward speed @ angle
		speed = 3,
		entropy = 0, --   0 <= entropy <= 1
		-- Altitude boundries
		min_altitude = min_altitude,
		max_altitude = max_altitude,
		-- Center of Mass for the airplane
		com_x = 80,
		com_y = 34,
	}

	-- Load the plane sprite
	obj.image = lg.newImage("plane.png")
	obj.min_altitude = obj.min_altitude - obj.image:getHeight()

	return setmetatable(obj, Plane)
end

-- Update the plane's position relative to its angle and speed
function Plane:update(dt)
	-- Entropy calculations
	self.angle = self.angle + math.random(-1,1) * self.speed * self.entropy / 5
	
	--local angle = self.angle + 90
	-- Update ax/ay
	local dx = self.speed * math.cos(math.rad(self.angle))
	local dy = self.speed * -math.sin(math.rad(self.angle))
	
	-- Bound dx/dy to +/-5
	dx = math.min(math.max(-5, dx), 5)
	dy = math.min(math.max(-5, dy), 5)

	-- Make the plane easier to level
	if(dx < 0.1 and dx > -0.1) then
		self.dx = 0
	end
	if(dy < 0.1 and dy > -0.1) then
		self.dy = 0
	end
		
	-- Update the position
	self.x = self.x + dx
	self.y = self.y + dy

	-- Correct when it goes too high/too low
	-- FIXME Smooth this
	self.y = math.min(math.max(self.min_altitude, self.y), self.max_altitude - self.image:getHeight())
	if(self.y == self.max_altitude - self.image:getHeight()) then
		self.angle = 0
	elseif(self.y == self.min_altitude) then
		self.angle = 0
	end
end

-- Draw the plane graphic onto the screen
-- We always draw the plane in the middle of the screen, except when we're near an edge
function Plane:draw()
	-- Get the current rendering area
	local view_x, view_y, view_width, view_height = lg.getScissor()

	local view_center_x = (view_width/2 - self.com_x)
	local view_center_y = (view_height/2 - self.com_y)

	-- Find the plane position
	local py = 0
	-- Plane is in the upper region and has to leave center (higher)
	if p["y"] > (self.max_altitude - view_center_y) then
--		print ("Mode: Upper " .. p["y"] .. " " .. view_center_y )
		py = self.max_altitude - p["y"]
	-- Plane is in the lower region and has to leave center (lower)
	elseif p["y"] < view_center_y - self.min_altitude then
--		print ("Mode: Lower " .. p["y"] .. " " .. view_center_y )
		py = view_height - (p["y"] + 50)--+ self.image:getHeight())
	-- Centered
	else
--		print ("Mode: Center " .. p["y"] .. " " .. view_center_y )
		py = view_center_y
	end
	-- print ("py:" .. py)
	
	-- Save the current coordinate system
	lg.push()

	-- Translate the screen
	lg.translate(view_center_x, py)
	lg.rotate(math.rad(self.angle))
	lg.translate(-view_center_x, -py)
	lg.setColor(255,255,255,255)
	lg.draw(self.image, view_center_x, py)
	
	-- DEBUG - draw a dot at the plane's rotation point position
	lg.setColor(255,0,0,255)
	lg.circle('fill', view_center_x, py, 3)

	-- Restore the coordinate system
	lg.pop()
end

return Plane

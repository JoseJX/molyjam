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
	obj.image = lg.newImage("graphics/plane.png")
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
	-- FIXME Ceiling smoothing works/ground smoothing not an issue once crashing implemented
	self.y = math.min(math.max(self.min_altitude, self.y), self.max_altitude - self.image:getHeight())
	-- Flying too high
	if(self.y >= self.max_altitude - window_height/2) then
		-- Smooth forward
		if(self.angle >= 270) then
			self.angle = self.angle + 2
			if(self.angle >= 360) then
				self.angle = 0
			end
		-- Smooth backward
		elseif(self.angle < 270 and self.angle > 180) then
			self.angle = self.angle - 2
			if(self.angle < 180) then
				self.angle = 180
			end
		end
	-- Flying too low
	elseif(self.y == self.min_altitude) then
		self.angle = 0
	end
end

-- Draw the plane graphic onto the screen
-- We always draw the plane in the middle of the screen, except when we're near an edge
function Plane:draw()
	-- Get the current window area
	local window_x, window_y, window_width, window_height = lg.getScissor()

	-- Find the plane position in the window area, X is always the same
	local plane_x = window_x + window_width/2
	local plane_y = 0

	-- If the plane's altitude is below 1/2 the screen height, let it move in the y direction
	if self.y < window_height/2 then
		plane_y = window_y + (window_height - self.y)
	-- If the plane's altitude is within 1/2 the screen height of the top, let it move in the y direction
	elseif self.y > self.max_altitude - window_height/2 then
		plane_y = window_y + (self.max_altitude - self.y)
	-- All other times, we center it
	else
		plane_y = window_y + window_height/2
	end
	
	-- Save the current coordinate system
	lg.push()

	-- Translate the drawing coordinates
	lg.translate(plane_x, plane_y)
	lg.rotate(math.rad(self.angle))
	lg.translate(-plane_x, -plane_y)
	lg.setColor(255,255,255,255)
	lg.draw(self.image, plane_x - self.com_x, plane_y - self.com_y)

	-- DEBUG - draw a dot at the plane's rotation point position
	-- lg.setColor(255,0,0,255)
	-- lg.circle('fill', plane_x, plane_y, 3)

	-- Restore the coordinate system
	lg.pop()
end

return Plane

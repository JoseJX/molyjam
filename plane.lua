-- Logic for rendering the plane and parsing the plane player's actions
local Plane = {}
Plane.__index = Plane

local lg = love.graphics

function Plane:new(x_pos, y_pos, min_altitude, max_altitude)
	local obj = { 
		-- Image data
		image = nil,	
		x = x_pos,
		y = y_pos,
		angle = 0,
		speed = 3,
		entropy = 0, --   0 <= entropy <= 1
		min_altitude = min_altitude,
		max_altitude = max_altitude,
	}

	-- Load the plane sprite
	obj.image = lg.newImage("plane.png")
	obj.min_altitude = obj.min_altitude - obj.image:getHeight()

	return setmetatable(obj, Plane)
end

-- Forward motion is always 5 units
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

-- We always draw the plane in the middle of the screen, except when we're near an edge
function Plane:draw()
	-- Get the current rendering area
	local view_x, view_y, view_width, view_height = lg.getScissor()

	local view_center_x = (view_width - self.image:getWidth()) / 2
	local view_center_y = (view_height - self.image:getHeight()) / 2

	-- Find the plane position
	local py = 0
	-- Plane is in the upper region and has to leave center (higher)
	if p["y"] > (self.max_altitude - view_center_y) then
		py = self.max_altitude - p["y"]
	-- Plane is in the lower region and has to leave center (lower)
	elseif p["y"] < view_center_y then
		py = view_height - (p["y"] + self.image:getHeight())
	-- Centered
	else
		py = view_center_y
	end
		
	-- Save the current coordinate system
	lg.push()

	-- Translate the screen
	lg.translate(view_center_x, py)
	lg.rotate(math.rad(self.angle))
	lg.translate(-view_center_x, -py)
	lg.setColor(255,255,255,255)
	lg.draw(self.image, view_center_x, py)

	-- Restore the coordinate system
	lg.pop()
end

return Plane

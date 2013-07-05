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
		angle = 0,
		speed = 3,
		entropy = 0, --   0 <= entropy <= 1
	}

	-- Load the plane sprite
	obj.image = lg.newImage("plane.png")

	return setmetatable(obj, Plane)
end

-- Forward motion is always 5 units
function Plane:update(dt)

	-- Entropy calculations
	--entropy = math.min(math.max(0, (self.x-10000)/10000), 1)
	--dx = dx + self.speed*(math.random(-0.5,0.5)*entropy)
	--dy = dy + self.speed*(math.random(-0.5,0.5)*entropy)
	self.angle = self.angle + (math.random(-1,1) * self.speed * self.entropy)
	if(self.angle > 360) then
		self.angle = self.angle - 360
	elseif(self.angle < 0) then
		self.angle = self.angle + 360
	end
	
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
	if(self.y > max_altitude) then
		lg.draw(self.image, screen_width/4, screen_height/2-(self.y-max_altitude))
	elseif(self.y < 0) then
		lg.draw(self.image, screen_width/4, screen_height/2-self.y)
	else
		lg.draw(self.image, screen_width/4, screen_height/2)
	end
	
	--DEBUG
	--lg.print(self.entropy, window_width*.4, UI_score_oft_V)

	-- Restore the coordinate system
	lg.pop()
end

return Plane

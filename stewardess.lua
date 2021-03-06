--- The stewardess passes back and forth in front of the passenger view
----- Can catch the phone user, and prevent the user from talking
local Stewardess = {}
Stewardess.__index = Stewardess

local lg = love.graphics
local stewardess_state = {
	"Waiting",
	"Walking",
	"Yelling"
}

function Stewardess:new(wpl, wpr)
	local obj = { 
		-- Image data
		images = {},
		state = stewardess_state[1],
		speed = 1,
		instance_rate = 0.002,
		direction = "right",
		x = 1,
		walk_path_left = wpl,
		walk_path_right = wpr,
		walk_distance = wpr - wpl,
		width = 0,
		height = 0,
	}

	-- Load all of the stewardess sprites
	table.insert(obj.images, lg.newImage("graphics/stewardess.png"))
	obj.width = obj.images[1]:getWidth()
	obj.height = obj.images[1]:getHeight()
	return setmetatable(obj, Stewardess)
end

-- Decide if we're starting a new stewardess walk-by
function Stewardess:update(dt, phone_state)
	-- See if we have a stewardess to move
	if (self.state == "Waiting") then
		if math.random() < self.instance_rate then
			self.state = stewardess_state[2]
			if self.direction == "right" then
				self.x = -self.images[1]:getWidth()
			else
				self.x = self.walk_distance + self.images[1]:getWidth()
			end
		end
	-- Move her
	elseif (self.state == "Walking") then
		if (self.direction == "right") then	
			self.x = self.x + self.speed
			if self.x > self.walk_distance then
				self.state = "Waiting"
				self.direction = "left"
			end
		else
			self.x = self.x - self.speed
			if self.x < 0 then
				self.state = "Waiting"
				self.direction = "right"
			end
		end
	end
	
	-- Check if the player is using the phone when the stewardess is there?
	local using = (phone_state == "Talking" or phone_state == "Using" or phone_state == "Missed" or phone_state == "Insulted" or phone_state == "Failed" or phone_state == "Won") 
	if using == true and self.state == "Walking" then
		local left_side = ((self.walk_path_right - self.walk_path_left) / 3) - self.width 
		local right_side = (2*(self.walk_path_right - self.walk_path_left) / 3)
		if self.x > left_side and self.x < right_side and self.direction == "right" then
			return true
		end
		left_side = ((self.walk_path_right - self.walk_path_left) / 3) + self.width
		right_side = (2*(self.walk_path_right - self.walk_path_left) / 3) + self.width 
		if self.x > left_side and self.x < right_side and self.direction == "left" then
			return true
		end
	end
	return false
end

-- Draw the stewardess image
function Stewardess:draw()
	if (self.state == "Walking") then
		local x = self.x + self.walk_path_left
		lg.setColor(255,255,255,255)
		if (self.direction == "right") then	
			lg.draw(self.images[1], x, lg.getHeight() - (self.height + 5), 0, 1, 1)
		else
			lg.draw(self.images[1], x, lg.getHeight() - (self.height + 5), 0, -1, 1)
		end
	end
end

return Stewardess

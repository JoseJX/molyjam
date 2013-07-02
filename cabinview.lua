local Stewardess = require 'stewardess'

-- Draw the cabin view, including the caller, the seats, the stewardess, the phone
local CabinView = {}
CabinView.__index = CabinView

local lg = love.graphics

function CabinView:new()
	local obj = { 
		-- Image data
		image = nil,	
		-- Stewardess
		s = nil
	}

	-- Load the cabin sprite
	obj.image = lg.newImage("cabin.png")
	return setmetatable(obj, CabinView)
end

-- Update the cabin view
function CabinView:update(dt)
	self.s:update(dt)
end

-- We always draw the cabin view at the bottom of the right panel, possibly add rotation here
function CabinView:draw()
	win_x, win_y, win_width, win_height = lg.getScissor()
	lg.setColor(255,255,255,255)
	lg.draw(self.image, win_x, win_height - self.image:getHeight())
	self.s:draw()
end

return CabinView

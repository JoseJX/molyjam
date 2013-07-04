local Stewardess = require 'stewardess'

-- Draw the cabin view, including the caller, the seats, the stewardess, the phone
local CabinView = {}
CabinView.__index = CabinView

local lg = love.graphics

function CabinView:new()
	local obj = { 
		-- Image data
		cabin = nil,	
		phone = nil,
		-- Stewardess
		s = nil
	}

	-- Load the cabin sprite
	obj.cabin = lg.newImage("graphics/cabin.png")

	-- Load the phone sprite
	obj.phone = lg.newImage("graphics/phone.png")

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
	lg.draw(self.cabin, win_x, win_height - self.cabin:getHeight())
	lg.draw(self.phone, win_x, win_height)
	self.s:draw()
end

return CabinView

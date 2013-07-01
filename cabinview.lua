-- Draw the cabin view, including the caller, the seats, the stewardess, the phone
local CabinView = {}
CabinView.__index = CabinView

local lg = love.graphics

function CabinView:new()
	local obj = { 
		-- Image data
		image = nil,	
	}

	-- Load the cabin sprite
	obj.image = lg.newImage("cabin.png")

	return setmetatable(obj, CabinView)
end

-- We always draw the cabin view at the bottom of the right panel, possibly add rotation here
function CabinView:draw(x, y)
	lg.setColor(255,255,255,255)
	lg.draw(self.image, x, y)
end

return CabinView

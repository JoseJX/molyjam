-- An obstruction in the plane view
local Obstruction = {}
Obstruction.__index = Obstruction

local lg = love.graphics
local UI_button_width = 50
local UI_button_height = 30
local UI_bar_width = 50

function Obstruction:new(img, behaviour)
	local obj = { 
		-- Game location
		x = x,
		y = y,
		-- Obstruction image
		img = nil,
		-- Obstruction behavior
		behaviour = behaviour,
	}
	return setmetatable(obj, Obstruction)
end

-- Update the location based on the behavior
function Obstruction:update(dt)
end

-- Draw the obstruction
function Obstruction:draw(x, y, width, height)
	
end

return Obstruction

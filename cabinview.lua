local Stewardess = require 'stewardess'
local Button = require 'button'

-- Draw the cabin view, including the caller, the seats, the stewardess, the phone
local CabinView = {}
CabinView.__index = CabinView

local lg = love.graphics

local phone_states = {
	"hiding",
	"talking"
}

function CabinView:new()
	local obj = { 
		-- Image data
		cabin = nil,	
		phone = nil,

		-- State of the phone user
		phone_state = "hiding",

		-- Stewardess
		s = nil,

		-- Buttons
		button_hide = nil,
		button_talk = nil,

	}

	-- Load the cabin sprite
	obj.cabin = lg.newImage("graphics/cabin.png")

	-- Load the phone sprite
	obj.phone = lg.newImage("graphics/phone.png")

	-- Create the buttons
	obj.button_hide = Button:new("Hide Phone", 0, 50, 150, 30)
	obj.button_talk = Button:new("Use Phone", 0, 50, 150, 30)

	return setmetatable(obj, CabinView)
end

-- Update the cabin view
function CabinView:update(dt)
	self.s:update(dt)
end

-- We got a mouse press, check to see if we need to update anything
function CabinView:mousepressed(x,y,button)
	if self.button_hide.visible == true and self.button_hide:check(x, y, button) then
		self.phone_state = "hiding"
	end
	if self.button_talk.visible == true and self.button_talk:check(x, y, button) then
		self.phone_state = "talking"
	end
end

-- Set the state of the phone user
function CabinView:phoneState(state)
	self.phone_state = state
end

-- We always draw the cabin view at the bottom of the right panel, possibly add rotation here
function CabinView:draw()
	win_x, win_y, win_width, win_height = lg.getScissor()
	lg.setColor(255,255,255,255)
	-- Draw the cabin
	lg.draw(self.cabin, win_x, win_y)
	-- Draw the phone
	if self.phone_state == "hiding" then
		lg.draw(self.phone, win_x + 300, win_y + 307)
	else
		lg.draw(self.phone, win_x + 194, win_y + 94)

		-- Draw a speech bubble
		-- FIXME
	end
	
	-- Draw the buttons
	if self.s.state == "Walking" then
		-- Figure out where to draw buttons
		if self.s.direction == "left" then
			-- Draw the hide button
			if self.s.x > win_width - (win_width / 4) then
				self.button_hide:setXY(win_x + 50, win_y + 50)
				self.button_hide:draw()
				self.button_hide.visible = true
				self.button_talk.visible = false
			elseif self.s.x < (win_width / 2) then
				self.button_talk:setXY(win_x + 450, win_y + 50)
				self.button_talk:draw()
				self.button_talk.visible = true
				self.button_hide.visible = false
			end
		-- Walking right
		else
			-- Draw the hide button
			if self.s.x > win_width - (win_width / 2) then
				self.button_talk:setXY(win_x + 50, win_y + 50)
				self.button_talk:draw()
				self.button_talk.visible = true
				self.button_hide.visible = false
			elseif self.s.x < (win_width / 4) then
				self.button_hide:setXY(win_x + 450, win_y + 50)
				self.button_hide:draw()
				self.button_talk.visible = false
				self.button_hide.visible = true
			end
		end
	elseif self.s.state == "Waiting" then
		self.button_hide.visible = true
		self.button_hide:draw()
		self.button_talk.visible = true
		self.button_talk:draw()
	end

	-- Draw the stewardess
	self.s:draw()

end

return CabinView

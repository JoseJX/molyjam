local Stewardess = require 'stewardess'
local Button = require 'button'

-- Draw the cabin view, including the caller, the seats, the stewardess, the phone
local CabinView = {}
CabinView.__index = CabinView

local lg = love.graphics

local phone_states = {
	"Hiding",
	"Talking",
	"Caught"
}

local UI_ht_button_height = 30

function CabinView:new(wpl, wpr, y)
	local obj = { 
		-- Image data
		cabin = nil,	
		phone = nil,

		-- State of the phone user
		phone_state = "Hiding",

		-- Stewardess
		s = nil,

		-- Buttons
		button_hide = nil,
		button_talk = nil,

		-- Cabin width measurements
		wpl = wpl,
		wpr = wpr
	}

	-- Load the cabin sprite
	obj.cabin = lg.newImage("graphics/cabin.png")

	-- Load the phone sprite
	obj.phone = lg.newImage("graphics/phone.png")

	-- Create the buttons
	obj.button_hide = Button:new("Hide Phone", wpl, window_height - 1.5*UI_ht_button_height, obj.cabin:getWidth()/3, UI_ht_button_height)
	obj.button_talk = Button:new("Use Phone", wpl + 2*obj.cabin:getWidth()/3, window_height - 1.5*UI_ht_button_height, obj.cabin:getWidth()/3, UI_ht_button_height)

	-- Create the stewardess
	obj.s = Stewardess:new(wpl, wpr)

	return setmetatable(obj, CabinView)
end

-- Update the cabin view
function CabinView:update(dt)
	self.s:update(dt)
	-- Check if the player is using the phone when the stewardess is there?
	if self.phone_state == "Talking" and self.s.state == "Walking" then
		local left_side = ((self.wpr - self.wpl) / 3) - self.s.width 
		local right_side = (2*(self.wpr - self.wpl) / 3)
		print(self.s.x, left_side, right_side)
		if self.s.x > left_side and self.s.x < right_side and self.s.direction == "right" then
			self.phone_state = "Caught"
			print ("Caught")
		end
		left_side = ((self.wpr - self.wpl) / 3) + self.s.width
		right_side = (2*(self.wpr - self.wpl) / 3) + self.s.width 
		print(self.s.x, left_side, right_side)
		if self.s.x > left_side and self.s.x < right_side and self.s.direction == "left" then
			self.phone_state = "Caught"
			print ("Caught")
		end
	end
end

-- We got a mouse press, check to see if we need to update anything
function CabinView:mousepressed(x,y,button)
	if self.button_hide.visible == true and self.button_hide:check(x, y, button) then
		if self.button_hide.state == true then
			self.phone_state = "Hiding"
		end
		return "Hiding"
	end
	if self.button_talk.visible == true and self.button_talk:check(x, y, button) then
		if self.button_talk.state == true then
			self.phone_state = "Talking"
		end
		return "Talking"
	end
end

-- We always draw the cabin view at the bottom of the right panel, possibly add rotation here
function CabinView:draw()
	win_x, win_y, win_width, win_height = lg.getScissor()
	lg.setColor(255,255,255,255)
	-- Draw the cabin
	lg.draw(self.cabin, win_x, win_y)

	-- Draw the phone in the correct position
	if self.phone_state == "Hiding" then
		-- Draw the phone under the seat
		lg.draw(self.phone, win_x + 300, win_y + 307)
	else
		-- Draw the phone in use
		lg.draw(self.phone, win_x + 194, win_y + 94)
		if self.phone_state == "Caught" then
			lg.setColor(255,0,0,64)
--			lg.rectangle('fill', win_x + win_width/3, win_y, win_width/3, win_height)
			lg.rectangle('fill', win_x, win_y, win_width, win_height)
		end
	end
	
	-- Draw the stewardess
	self.s:draw()
	
	-- Draw the button for hiding/using the phone
	self.button_talk:draw()
	self.button_hide:draw()

	-- DEBUG
	-- Draw the lines that indicate the thirds
	lg.setColor(255,0,0,255)
	lg.line(win_x + win_width / 3, win_y, win_x + win_width / 3, win_y + win_height)	
	lg.line(win_x + 2*win_width / 3, win_y, win_x + 2*win_width / 3, win_y + win_height)	

end

return CabinView

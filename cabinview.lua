local Stewardess = require 'stewardess'
local Button = require 'button'

-- Draw the cabin view, including the caller, the seats, the stewardess, the phone
local CabinView = {}
CabinView.__index = CabinView

local lg = love.graphics

local phone_states = {
	"Hiding",
	"Using",
	"Talking",
	"OnHold",
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
		laste_state = "Hiding",

		-- Stewardess
		s = nil,

		-- Buttons
		button_hide = nil,
		button_talk = nil,

		-- Cabin width measurements
		wpl = wpl,
		wpr = wpr,

		-- Blinking speed
		blink_state = false,
		blink_rate = 0.5,
		blink_dt = 0,
		blink_ct = 0,
		blink_count = 8,
	}

	-- Load the cabin sprite
	obj.cabin = lg.newImage("graphics/cabin.png")

	-- Load the phone sprite
	obj.phone = lg.newImage("graphics/phone.png")

	-- Create the buttons
	obj.button_hide = Button:new("Hide Phone", wpl, window_height - 1.5*UI_ht_button_height, obj.cabin:getWidth()/3, UI_ht_button_height, 'center')
	obj.button_talk = Button:new("Use Phone", wpl + 2*obj.cabin:getWidth()/3, window_height - 1.5*UI_ht_button_height, obj.cabin:getWidth()/3, UI_ht_button_height, 'center')

	-- Create the stewardess
	obj.s = Stewardess:new(wpl, wpr)

	return setmetatable(obj, CabinView)
end

-- Update the cabin view
function CabinView:update(dt)
	print (self.phone_state)
	if self.s:update(dt, self.phone_state) == true then
		self.phone_state = "Caught"
		c.phones_left = c.phones_left - 1
		self.button_hide.enabled = false
		self.button_talk.enabled = false
	end

	if self.phone_state == "Caught" then
		self.blink_dt = self.blink_dt + dt
		if self.blink_dt > self.blink_rate then
			self.blink_state = not self.blink_state
			self.blink_dt = 0
			self.blink_ct = self.blink_ct + 1
			if self.blink_ct > self.blink_count then
				self.blink_ct = 0
				self.phone_state = "Hiding"
				c.caller_id = 0
				self.button_hide.enabled = true
				self.button_talk.enabled = true
			end
		end
	end
end

-- We got a mouse press, check to see if we need to update anything
function CabinView:mousepressed(x,y,button)
	if self.button_hide.visible == true and self.button_hide:check(x, y, button) then
		if self.button_hide.state == true then
			if self.phone_state == "Talking" then
				self.phone_state = "OnHold"
			else
				self.phone_state = "Hiding"
			end
		end
	end
	if self.button_talk.visible == true and self.button_talk:check(x, y, button) then
		if self.button_talk.state == true then
			if self.phone_state == "OnHold" then
				self.phone_state = "Talking"
			else
				self.phone_state = "Using"
			end
		end
	end
	return self.phone_state
end

-- We always draw the cabin view at the bottom of the right panel, possibly add rotation here
function CabinView:draw()
	win_x, win_y, win_width, win_height = lg.getScissor()

	-- Save the current coordinate system
	lg.push()

	-- Rotate based on the plane rotation
	lg.translate(win_x + win_width/2, win_y + win_height/2)
	lg.rotate(math.rad(p.angle))
	lg.translate(-(win_x + win_width/2), -(win_y + win_height/2))

	lg.setColor(255,255,255,255)
	-- Draw the cabin
	lg.draw(self.cabin, win_x, win_y)

	-- Draw the phone in the correct position
	if self.phone_state == "Hiding" or self.phone_state == "OnHold" then
		-- Draw the phone under the seat
		lg.draw(self.phone, win_x + 300, win_y + 307)
	else
		-- Draw the phone in use
		lg.draw(self.phone, win_x + 194, win_y + 94)
		if self.phone_state == "Caught" and self.blink_state == true then
			lg.setColor(255,0,0,64)
			lg.rectangle('fill', win_x, win_y, win_width, win_height)
		end
	end
	
	-- Draw the stewardess
	self.s:draw()

	-- Restore the coordinates
	lg.pop()
	
	-- Draw the button for hiding/using the phone
	self.button_talk:draw()
	self.button_hide:draw()

end

return CabinView

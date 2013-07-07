local Stewardess = require 'stewardess'
local Button = require 'button'

-- Draw the cabin view, including the caller, the seats, the stewardess, the phone
local CabinView = {}
CabinView.__index = CabinView

local lg = love.graphics

local UI_ht_button_height = 30

function CabinView:new(cabin_window)
	local obj = { 
		-- Cabin window area
		window = cabin_window,

		-- Image data
		cabin = nil,	
		phone = nil,

		-- Stewardess
		s = nil,

		-- Buttons
		button_hide = nil,
		button_talk = nil,

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
	local b_y = cabin_window[2] + cabin_window[4] - 1.5 * UI_ht_button_height
	obj.button_hide = Button:new("Hide Phone", cabin_window[1], b_y, cabin_window[3]/3, UI_ht_button_height, 'center')
	obj.button_talk = Button:new("Use Phone", cabin_window[1] + 2*cabin_window[3]/3, b_y, cabin_window[3]/3, UI_ht_button_height, 'center')

	-- Create the stewardess
	obj.s = Stewardess:new(cabin_window[1], cabin_window[1] + cabin_window[3])

	return setmetatable(obj, CabinView)
end

-- Update the cabin view
function CabinView:update(dt, call_state)
	-- Check if the stewardess has caught the user
	if self.s:update(dt, call_state) == true then
		self.button_hide.enabled = false
		self.button_hide.state = false
		self.button_talk.enabled = false
		self.button_talk.state = false
		-- Totally...
		return true
	end
	return false
end

-- This function returns true when the blinking is done
function CabinView:blink(dt)
	self.blink_dt = self.blink_dt + dt
	if self.blink_dt > self.blink_rate then
		self.blink_state = not self.blink_state
		self.blink_dt = 0
		self.blink_ct = self.blink_ct + 1
		if self.blink_ct > self.blink_count then
			self.blink_ct = 0
			self.button_hide.enabled = true
			self.button_talk.enabled = true
			return true
		end
	end
	return false
end

-- We got a mouse press, check to see if we need to update anything
function CabinView:mousepressed(x,y,button, call_state)
	if self.button_hide.visible == true and self.button_hide:check(x, y, button) then
		if self.button_hide.state == true then
			if call_state == "Talking" then
				return "OnHold"
			else
				return "Hiding"
			end
		end
	end
	if self.button_talk.visible == true and self.button_talk:check(x, y, button) then
		if self.button_talk.state == true then
			if call_state == "OnHold" then
				return "Talking"
			else
				return "Using"
			end
		end
	end
	return nil
end

-- We always draw the cabin view at the bottom of the right panel, possibly add rotation here
function CabinView:draw(call_state)
	-- Set up the drawing coordinates
	win_x = self.window[1]
	win_y = self.window[2]
	win_width = self.window[3]
	win_height = self.window[4]
	lg.setScissor(win_x, win_y, win_width, win_height)

	-- Save the current coordinate system
	lg.push()

	-- Rotate and scale based on the plane rotation
	lg.translate(win_x + win_width/2, win_y + win_height/2)
	lg.rotate(math.rad(p.angle))
	lg.translate(-(win_x + win_width/2), -(win_y + win_height/2))
	-- FIXME: Scale for non-720p resolutions	

	lg.setColor(255,255,255,255)
	-- Draw the cabin
	lg.draw(self.cabin, win_x, win_y)

	-- Draw the phone in the correct position
	if call_state == "Hiding" or call_state == "OnHold" then
		-- Draw the phone under the seat
		lg.draw(self.phone, win_x + 300, win_y + 307)
	else
		-- Draw the phone in use
		lg.draw(self.phone, win_x + 194, win_y + 94)
		if call_state == "Caught" and self.blink_state == true then
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

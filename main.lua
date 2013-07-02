local Ground = require 'ground'
local Plane = require 'plane'
local CabinView = require 'cabinview'
local Caller = require 'caller'
local Button = require 'button'
local Stewardess = require 'stewardess'
local lg = love.graphics
local lk = love.keyboard

-- Level settings
length = 10000
height = 1200

-- Game settings
window_width = lg.getWidth()
window_height = lg.getHeight()

-- Graphics positioning constants
local UI_bar_height = 20
local UI_divider_width = 10
local UI_score_oft_H = 20
local UI_score_oft_V = 5
local UI_button_height = 30
local UI_button_width = 440
local UI_button_start_height = 80
local UI_button_spacer = 40
local UI_left_panel_x = 0
local UI_right_panel_x = window_height/2 + UI_divider_width

-- Buttons in the UI
buttons = {}
text = "Waiting for call..."

-- Load the game data on program start
function love.load()
	-- Generate terrain
	g = Ground:new()

	local max_ground_height = 200
	local start_height = max_ground_height / 2
	local delta = 5
	g:generate(height, length, max_ground_height, 0.03, 0.005)

	-- Load the plane sprite
	p = Plane:new(0, max_ground_height + 100)

	-- Load the cabin view
	cv = CabinView:new()

	-- Load the stewardess
	s = Stewardess:new(UI_right_panel_x, window_width)

	-- Load the callers
	c = Caller:new()

	-- Make some buttons
	for i=1,4 do
		table.insert(buttons, Button:new("Button #" .. i, window_width / 2 + UI_divider_width * 2, UI_bar_height + UI_button_start_height + (UI_button_spacer * (i-1)), UI_button_width, UI_button_height))	
	end

	-- Set the button text
	buttons[1]:setText("Do you even lift?")
	buttons[2]:setText("That's how your mother likes it!")
	buttons[3]:setText("I know you are, but what am I?")
	buttons[4]:setText("How appropriate, you fight like a cow!")
end

-- Keypress callbacks that aren't handled in the main update loop
function love.keypressed(key, unicode)
	if key == "escape" then
		love.event.push('quit')
	end
end

-- Mouse press callbacks
function love.mousepressed(x, y, button)
	for button_id, button in ipairs(buttons) do
		if button:check(x, y, true) then
			c:update()
		end
	end
end
function love.mousereleased(x, y, button)
	for button_id, button in ipairs(buttons) do
		button:check(x, y, false)
	end
end

-- Main update loop
function love.update(dt)
	if lk.isDown("down") then
		p["speed"] = p["speed"] - 0.1
		if p["speed"] < 3  then
			p["speed"] = 3
		end
	end
	if lk.isDown("up") then
		p["speed"] = p["speed"] + 0.1
		if p["speed"] > 8 then
			p["speed"] = 8
		end
	end

	if lk.isDown("right") then
		p["angle"] = p["angle"] + 1
		if(p["angle"] > 360) then
			p["angle"] = p["angle"] - 360
		end
	end

	if lk.isDown("left") then
		p["angle"] = p["angle"] - 1
		if(p["angle"] < 0) then
			p["angle"] = p["angle"] + 360
		end
	end

	-- Update the plane status
	p:update(dt)

	-- Update the stewardess
	s:update(dt)
end

-- Drawing function, all drawing must be done from here!
function love.draw()
	-- Draw the Player 1 screen
	g:draw(p["x"], p["y"], window_width/2, window_height)
	p:draw(height, level, window_width/2, window_height)
	
	-- Draw the Player 2 screen
	lg.setColor(128,128,128,255)
	lg.rectangle('fill', window_width/2, 0, window_width/2, window_height)
	
	-- Draw the divider line between the two screens
	lg.setColor(255,255,0,255)
	lg.rectangle('fill', window_width/2, 0, UI_divider_width, window_height)
	
	-- Draw the UI
	lg.setColor(0,0,0,255)
	lg.rectangle('fill', 0, 0, window_width, UI_bar_height)

	-- Draw the UI text
	lg.setColor(255,255,255,255)
	lg.print("Player 1 Score: ", UI_score_oft_H, UI_score_oft_V)	
	lg.print("Player 2 Score: ", window_width/2 + UI_score_oft_H + UI_divider_width, UI_score_oft_V)	

	-- Draw the cabin view
	cv:draw(window_width/2 + UI_divider_width, window_height - cv["image"]:getHeight())
	
	-- Draw the stewardess
	s:draw()

	-- Draw the callers
	c:draw(window_width - 160, UI_bar_height)
	
	-- Draw the text
	lg.setColor(255,255,255,255)
	lg.print(c:getText(), window_width/2 + UI_divider_width * 2, UI_bar_height + 10)

	-- Draw the buttons
	for button_id, button in ipairs(buttons) do
		button:draw()
	end
end


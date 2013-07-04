local Ground = require 'ground'
local Plane = require 'plane'
local CabinView = require 'cabinview'
local Caller = require 'caller'
local Stewardess = require 'stewardess'
local lg = love.graphics
local lk = love.keyboard

-- Level settings
length = 100000
height = 2000

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
local UI_player_window_width = (window_width / 2) - (UI_divider_width/2)
local UI_player_window_height = window_height - UI_bar_height
local UI_right_panel_x = UI_player_window_width + UI_divider_width

draw_ct = 0

-- Load the game data on program start
function love.load()
	-- Generate terrain
	g = Ground:new()

	local max_ground_height = 200
	local start_height = max_ground_height / 2
	local delta = 5
	g:generate(height, length, max_ground_height, 0.03, 0.005)

	-- Load the plane sprite
	p = Plane:new(0, max_ground_height + 100, 100, height)

	-- Load the cabin view
	cv = CabinView:new(UI_right_panel_x, window_width, window_height)

	-- Load the callers
	c = Caller:new()
end

-- Keypress callbacks that aren't handled in the main update loop
function love.keypressed(key, unicode)
	-- Quit the game
	if key == "escape" then
		love.event.push('quit')
	end

	-- DEBUG KEYS
	-- Update text message
	if key == "t" then
		c:updateText(false, "player")
		c:updateText(false, "caller")
	end
end

-- Mouse press callbacks
function love.mousepressed(x, y, button)
	c.phone_state = cv:mousepressed(x, y, true)
end
function love.mousereleased(x, y, button)
	cv:mousepressed(x, y, false)
end

-- Main update loop
function love.update(dt)
	-- Pitch the plane up
	if lk.isDown("right") or lk.isDown("d") then
		p["angle"] = p["angle"] + 1
		if(p["angle"] > 360) then
			p["angle"] = p["angle"] - 360
		end
	end
	-- Pitch the plane down
	if lk.isDown("left") or lk.isDown("a") then
		p["angle"] = p["angle"] - 1
		if(p["angle"] < 0) then
			p["angle"] = p["angle"] + 360
		end
	end
	-- Increase throttle
	if lk.isDown("up") then
		p["speed"] = p["speed"] + 0.1
		if p["speed"] > 8 then
			p["speed"] = 8
		end
	end
	-- Decrease throttle
	if lk.isDown("down") then
		p["speed"] = p["speed"] - 0.1
		if p["speed"] < 3  then
			p["speed"] = 3
		end
	end

	--------------------
	-- DEBUG keys
	--------------------
	
	-- Decrease entropy
	if lk.isDown("[") then
		p["entropy"] = p["entropy"] - .1
		if(p["entropy"] < 0) then
			p["entropy"] = 0
		end
	end
	-- Increase entropy
	if lk.isDown("]") then
		p["entropy"] = p["entropy"] + .1
		if(p["entropy"] > 1) then
			p["entropy"] = 1
		end
	end

	------------------
	-- Update statuses
	------------------
	-- Update the plane status
	p:update(dt)

	-- Update the cabin view
	cv:update(dt)
end

-- Drawing function, all drawing must be done from here!
function love.draw()
	---------------------------
	-- Draw the Player 1 screen
	---------------------------
	lg.setScissor(0, UI_bar_height, UI_player_window_width, UI_player_window_height)
	-- Ground
	g:draw(p["x"], p["y"])
	-- Plane
	p:draw(height, level)
	
	---------------------------
	-- Draw the Player 2 screen
	---------------------------
	-- Cabin view
	lg.setScissor(UI_player_window_width + UI_divider_width, window_height - cv.cabin:getHeight(),UI_player_window_width, cv.cabin:getHeight())
	cv:draw()

	-- Caller Window
	lg.setScissor(UI_player_window_width + UI_divider_width, UI_bar_height, UI_player_window_width, UI_player_window_height - cv.cabin:getHeight())
	lg.setColor(128,128,128,255)
	lg.rectangle('fill', window_width/2, 0, window_width/2, window_height)
	c:draw()
	
	--------------
	-- Draw the UI
	--------------
	-- Draw the divider line between the two screens
	lg.setScissor(0,0,lg.getWidth(),lg.getHeight())
	lg.setColor(255,255,0,255)
	lg.rectangle('fill', window_width/2 - UI_divider_width/2, 0, UI_divider_width, window_height)
	
	-- Draw the score bar
	lg.setColor(0,0,0,255)
	lg.rectangle('fill', 0, 0, window_width, UI_bar_height)

	-- Draw the UI text
	lg.setColor(255,255,255,255)
	lg.print("Player 1 Score: ", UI_score_oft_H, UI_score_oft_V)
	lg.print("Player 2 Score: ", window_width/2 + UI_score_oft_H + UI_divider_width, UI_score_oft_V)	

	--DEBUG stuff
	lg.print(p["angle"], window_width*.1, UI_score_oft_V)
	lg.print(math.floor(p["x"]), window_width*.2, UI_score_oft_V)
	lg.print(math.floor(p["y"]), window_width*.3, UI_score_oft_V)
	lg.print(p["entropy"], window_width*.4, UI_score_oft_V)

	if draw_ct > 5 then
		lg.setColor(0,0,255,255)
		lg.circle('fill', UI_player_window_width/2, UI_player_window_height / 2 + UI_bar_height, 3)
		draw_ct = 0
	end
	draw_ct = draw_ct + 1
end


local Ground = require 'ground'
local Plane = require 'plane'
local CallerGame = require 'caller_game'
local lg = love.graphics
local lk = love.keyboard

-- Engine settings
window_width = lg.getWidth()
window_height = lg.getHeight()

-- Game settings
local level_length = 100000
local level_height = 2000
local caller_rate = 0.005

-- Graphics positioning constants (FIXME?)
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

-- State switcher 
state = {
	keypressed = nil,
	mousepressed = nil,
	mousereleased = nil,
	update = nil,
	draw = nil,
}

-- Introduction variables
local intro_top_alpha = 255
local intro_bottom_alpha = 255
local fade_speed = 25

-------------------------------------------------------------------------------
-- Common logic
-------------------------------------------------------------------------------
-- Load the game data on program start
function love.load()
	-----------------
	-- Player 1
	-----------------
	-- Load the ground view
	g = Ground:new()

	-- Generate terrain
	local max_ground_height = 200
	local start_height = max_ground_height / 2
	local delta = 5
	g:generate(level_height, level_length, max_ground_height, 0.03, 0.005)

	-- Load the plane view
	p = Plane:new(0, max_ground_height + 100, 100, level_height)

	-----------------
	-- Player 2
	-----------------
	-- Create the game instance for player 2
	local p2_window = { UI_right_panel_x, UI_bar_height, UI_player_window_width, UI_player_window_height }
	p2 = CallerGame:new(p2_window)

	-----------------
	-- Introduction
	-----------------
	intro_img = lg.newImage('graphics/intro1.png')
	state.keypressed = intro_keypressed
	state.mousepressed = intro_keypressed
	state.mousereleased = intro_mousereleased
	state.update = intro_update
	state.draw = intro_draw
end

-- Function dispatcher
function love.keypressed(key, unicode)
	if not (state.keypressed == nil) then
		state.keypressed(key, unicode)
	end
end
function love.mousepressed(x, y, button)
	if not (state.mousepressed == nil) then
		state.mousepressed(x, y, button)
	end
end
function love.mousereleased(x, y, button)
	if not (state.mousereleased == nil) then
		state.mousereleased(x, y, button)
	end
end
function love.update(dt)
	if not (state.update == nil) then
		state.update(dt)
	end
end
function love.draw()
	if not (state.draw == nil) then
		state.draw()
	end
end

-------------------------------------------------------------------------------
-- Intro logic
-------------------------------------------------------------------------------
function intro_keypressed(key, unicode)
	if key == "escape" then
		love.event.push('quit')
	else
		quit_intro()
	end
end
function intro_mousepressed(x, y, button)
	-- Wait for release
end
function intro_mousepressed(x, y, button)
	quit_intro()
end
function intro_update(dt)
	if intro_top_alpha > 0 then
		intro_top_alpha = intro_top_alpha - fade_speed*dt
		if intro_top_alpha < 0 then
			intro_top_alpha = 0
		end
	elseif intro_bottom_alpha > 0 then
		intro_bottom_alpha = intro_bottom_alpha - fade_speed*dt		
		if intro_bottom_alpha < 0 then
			intro_bottom_alpha = 0
		end
	end
end
function intro_draw()
	lg.setColor(255,255,255,255)
	lg.draw(intro_img, 0, 0)
	lg.setColor(0,0,0,intro_top_alpha)
	lg.rectangle('fill', 0, 0, window_width, window_height/2)
	lg.setColor(0,0,0,intro_bottom_alpha)
	lg.rectangle('fill', 0, window_height/2, window_width, window_height/2)
end
-- Reset the functions to be dispatched
function quit_intro()
	state.keypressed = game_keypressed
	state.mousepressed = game_mousepressed
	state.mousereleased = game_mousereleased
	state.update = game_update
	state.draw = game_draw
end

-------------------------------------------------------------------------------
-- Game logic
-------------------------------------------------------------------------------
-- Keypress callbacks that aren't handled in the main update loop
function game_keypressed(key, unicode)
	-- Quit the game
	if key == "escape" then
		love.event.push('quit')
	end
end
-- Mouse press callbacks
function game_mousepressed(x, y, button)
	p2:mousepressed(x, y, true)
end
function game_mousereleased(x, y, button)
	p2:mousepressed(x, y, false)
end

-- Main update loop
function game_update(dt)
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

	-- Update the player 2 view
	p2:update(dt)
end

-- Drawing function, all drawing must be done from here!
function game_draw()
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
	p2:draw()
	
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
	-- lg.print(p["angle"], window_width*.1, UI_score_oft_V)
	-- lg.print(math.floor(p["x"]), window_width*.2, UI_score_oft_V)
	-- lg.print(math.floor(p["y"]), window_width*.3, UI_score_oft_V)
	-- lg.print(p["entropy"], window_width*.4, UI_score_oft_V)
end


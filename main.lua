local Ground = require 'ground'

-- Main game logic
window_x = 0
window_y = 100

window_width = 800
window_height = 600

-- Level settings
length = 10000
height = 1000

-- Load the game data on program start
function love.load()
	-- Generate terrain
	g = Ground:new()

	local max_ground_height = 300
	local start_height = max_ground_height / 2
	local delta = 5
	g:generate(length, max_ground_height, 0.05)
end

-- Keypress callbacks that aren't handled in the main update loop
function love.keypressed(key, unicode)
	if key == "escape" then
		love.event.push('quit')
	end
end

-- Main update loop
function love.update(dt)
	if love.keyboard.isDown("left") then
		window_x = window_x - 5
		if window_x < 0  then
			window_x = 0
		end
	elseif love.keyboard.isDown("right") then
		window_x = window_x + 5
		if window_x >= (length - window_width) then
			window_x = length - window_width
		end
	elseif love.keyboard.isDown("up") then
		window_y = window_y + 5
		if window_y >= (height - window_height) then
			window_y = height - window_height
		end
	elseif love.keyboard.isDown("down") then
		window_y = window_y - 5
		if window_y < 0  then
			window_y = 0
		end
	end
end

-- Drawing function, all drawing must be done from here!
function love.draw()
	g:draw(window_x, window_y, 800, 600)
end

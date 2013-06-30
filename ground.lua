-- Draw the ground/terrain
-- Polygon based, with random sprite decorations

local Ground = {}
Ground.__index = Ground

local lg = love.graphics

function Ground:new(ground_height)
	local obj = {
		ground = {},
		ground_height = ground_height or 100,
		min_hill_width = 10,
		max_hill_width = 30,
	}
	return setmetatable(obj, Ground)
end

-- Height compare
function height_compare(a,b)
	return a["height"] > b["height"]
end

-- Generate the hills
-- FIXME: Add the airport at the beginning and end
function Ground:generate(length, max_hill_height, hill_density)
	-- Generate the hills
	for x=1,math.floor(length * hill_density) do
		local hill = {
			height = math.random(self.ground_height, self.ground_height + max_hill_height),
			width = math.random(self.min_hill_width, self.max_hill_width),
			x = math.random(1,length)
		}
		table.insert(self.ground, hill)
	end

	-- Generate a sorted list of IDs for drawing
	table.sort(self.ground, height_compare)
end

-- Draw the terrain
function Ground:draw(view_x, view_y, view_width, view_height)
	-- Draw the background
	lg.setBackgroundColor(0,128,255,255)
	lg.clear()
	
	-- Set the ground color
	lg.setColor(0, 255, 128, 255)

	-- Are we low enough to draw the ground?
	if(view_y < 100) then
		local gh = view_height - (100 - view_y)
		love.graphics.polygon('fill', 0, view_height, 0, gh, view_width, gh, view_width, view_height)
	end

	-- Loop over all of the hills
	for hill_id, hill in ipairs(self.ground) do
		-- Are we drawing this hill?
		if(hill["x"] >= view_x - self.max_hill_width and hill["x"] <= (view_x + view_width + self.max_hill_width)) then
			-- Yup, draw the top arc
			lg.setColor(0, 255, 128, 255)
			local draw_y = view_height - (hill["height"] - view_y)
			local draw_x = hill["x"] - view_x
			lg.arc('fill', draw_x, draw_y, hill["width"], math.pi, 2*math.pi, 10)
			lg.setColor(0, 128, 0, 255)
			lg.arc('line', draw_x, draw_y, hill["width"], math.pi, 2*math.pi, 10)
			
			-- Then the rectangle
			lg.setColor(0, 255, 128, 255)
			lg.rectangle('fill', draw_x - hill["width"], draw_y - 1, 2 * hill["width"], view_height)
			lg.setColor(0, 128, 0, 255)
			lg.line(draw_x - hill["width"], draw_y - 1, draw_x - hill["width"], view_height)
			lg.line(draw_x + hill["width"], draw_y - 1, draw_x + hill["width"], view_height)
		end
	end
end

return Ground

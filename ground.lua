-- Draw the ground/terrain/clouds
local Ground = {}
Ground.__index = Ground

local lg = love.graphics

function Ground:new(ground_height)
	local obj = {
		ground = {},
		cloud_img = nil,
		clouds = {},
		ground_height = ground_height or 100,
		min_hill_width = 10,
		max_hill_width = 30,
		cloud_width = 100,
	}

	-- Load the cloud image
	obj.cloud_img = lg.newImage("cloud1.png")

	return setmetatable(obj, Ground)
end

-- Height compare
function height_compare(a,b)
	return a["height"] > b["height"]
end

-- Generate the hills
-- FIXME: Add the airport at the beginning and end
function Ground:generate(height, length, max_hill_height, hill_density, cloud_density)
	-- Generate the hills
	for x=1,math.floor(length * hill_density) do
		local hill = {
			height = math.random(self.ground_height, self.ground_height + max_hill_height),
			width = math.random(self.min_hill_width, self.max_hill_width),
			x = math.random(1,length)
		}
		table.insert(self.ground, hill)
	end

	-- Generate the clouds
	for x=1,math.floor(length * cloud_density) do
		local cloud = {
			height = math.random(max_hill_height, height),
			x = math.random(1,length)
		}
		table.insert(self.clouds, cloud)
	end

	-- Generate a sorted list of IDs for drawing
	table.sort(self.ground, height_compare)
end

-- Draw the terrain
function Ground:draw(view_x, view_y)
	-- Get the current view
	window_x, window_y, view_width, view_height = lg.getScissor()	

	-- Draw the background
	lg.setBackgroundColor(143,220,245,255)
	lg.clear()

	-- Set the ground color
	lg.setColor(8, 168, 12, 255)

	-- Are we low enough to draw the ground?
	if(view_y < self.ground_height) then
		local gh = view_height - (self.ground_height - view_y)
		lg.rectangle('fill', 0, view_height, view_width, gh)
--		love.graphics.polygon('fill', 0, view_height, 0, gh, view_width, gh, view_width, view_height)
	end
	
	local draw_to_y = view_height;
	if(view_y < self.ground_height / 2) then
		draw_to_y = view_height - ((self.ground_height/2) - view_y)
	end

	-- Loop over all of the hills
	for hill_id, hill in ipairs(self.ground) do
		-- Are we drawing this hill?
		if(hill["x"] >= view_x - self.max_hill_width and hill["x"] <= (view_x + view_width + self.max_hill_width) and hill["height"] > view_y - hill["width"]) then
			-- Yup, draw the top arc
			lg.setColor(8, 168, 12, 255)
			local draw_y = view_height - (hill["height"] - view_y)
			local draw_x = hill["x"] - view_x
			lg.arc('fill', draw_x, draw_y, hill["width"], math.pi, 2*math.pi, 10)
			lg.setColor(0, 100, 0, 255)
			lg.arc('line', draw_x, draw_y, hill["width"], math.pi, 2*math.pi, 10)
			
			-- Then the rectangle
			lg.setColor(8, 168, 12, 255)
			lg.rectangle('fill', draw_x - hill["width"], draw_y - 1, 2 * hill["width"], draw_to_y)
			lg.setColor(0, 100, 0, 255)
			lg.line(draw_x - hill["width"], draw_y - 1, draw_x - hill["width"], draw_to_y)
			lg.line(draw_x + hill["width"], draw_y - 1, draw_x + hill["width"], draw_to_y)
		end
	end

	-- Loop over all of the clouds
	for cloud_id, cloud in ipairs(self.clouds) do
		-- Are we drawing this cloud?
		if(cloud["x"] >= view_x - self.cloud_width and cloud["x"] <= (view_x + view_width + self.cloud_width) and cloud["height"] > view_y - self.cloud_width) then
			-- Draw the cloud
			lg.setColor(255,255,255,255)
			lg.draw(self.cloud_img, cloud["x"] - view_x, view_height - (cloud["height"] - view_y))
		end
	end
end

return Ground

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

-- Draw the terrain, relative to the plane position
function Ground:draw(plane_x, plane_y)
	-- Get the current draw box
	local window_x, window_y, window_width, window_height = lg.getScissor()	

	-- Draw the background sky
	lg.setBackgroundColor(143,220,245,255)
	lg.clear()

	-- Set the ground color
	lg.setColor(8, 168, 12, 255)

	-- If the render window isn't locked (far enough from ground)
	local view_max_alt = plane_y + (window_height / 2)
	local view_min_alt = plane_y - (window_height / 2)
	-- If the render window is loccked (close to ground)
	if (plane_y < window_height/2) then
		view_min_alt = 0
		view_max_alt = window_height
	end

	-- Draw the ground if needed
	if(view_min_alt < self.ground_height) then
		local ground_y = self.ground_height - view_min_alt
		lg.rectangle('fill', 0, window_height - ground_y, window_width, window_height)
	end
	
	-- Draw the hills
	for hill_id, hill in ipairs(self.ground) do
		-- Check if this hill is in view
		if ((hill["x"] >= plane_x - hill["width"]) and (hill["x"] <= plane_x + window_width + hill["width"]) and ((hill["height"] + 2*hill["width"])> view_min_alt)) then
			-- Yup, draw the top arc
			lg.setColor(8, 168, 12, 255)
			local hill_x = hill["x"] - plane_x
			local hill_y = window_height - (hill["height"] - view_min_alt)
			local draw_hill_y_to = hill_y + (hill["height"] - self.ground_height/2)
			lg.arc('fill', hill_x, hill_y, hill["width"], math.pi, 2*math.pi, 10)
			lg.setColor(0, 100, 0, 255)
			lg.arc('line', hill_x, hill_y, hill["width"], math.pi, 2*math.pi, 10)
			
			-- Then the rectangle
			lg.setColor(8, 168, 12, 255)
			lg.rectangle('fill', hill_x - hill["width"], hill_y - 1, 2 * hill["width"], draw_hill_y_to)
			lg.setColor(0, 100, 0, 255)
			lg.line(hill_x - hill["width"], hill_y - 1, hill_x - hill["width"], draw_hill_y_to)
			lg.line(hill_x + hill["width"], hill_y - 1, hill_x + hill["width"], draw_hill_y_to)
		end

	end
	
	-- Draw the clouds
	for cloud_id, cloud in ipairs(self.clouds) do
		-- Are we drawing this cloud?
		if(cloud["x"] >= plane_x - self.cloud_width and cloud["x"] <= (plane_x + window_width + self.cloud_width) and cloud["height"] > view_min_alt) then
			-- Draw the cloud
			lg.setColor(255,255,255,255)
			lg.draw(self.cloud_img, cloud["x"] - plane_x, window_height - (cloud["height"] - view_min_alt))
		end

	end
end

return Ground

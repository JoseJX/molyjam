-- Implements the caller minigame
local Button = require 'button'
local Bar = require 'bar'
local Utils = require 'utils'
local Caller = require 'caller'
local CabinView = require 'cabinview'
local Player2 = require 'player2'
local Text = require 'text'

local CallerGame = {}
CallerGame.__index = CallerGame

local lg = love.graphics
local caller_box_border = 10
local caller_box_width = 125 + caller_box_border
local caller_box_height = 200 + caller_box_border
local button_width = 70
local button_height = 30
local babble_rate = 5
local caller_rate = 0.05
local cabin_view_height = 400

function CallerGame:new(window)
	local obj = { 
		-- Window position and size
		win_x = window[1],
		win_y = window[2],
		win_w = window[3],
		win_h = window[4],

		-------------------------------------------
		-- Instances
		-------------------------------------------
		-- Caller Instance
		caller = nil,
		caller_window = nil,
		-- Player Instance
		player = nil,	
		-- Text Generator Instance
		text = nil,
		-- Cabin View
		cabin = nil,
		cabin_window = nil,

		-------------------------------------------
		-- Game configuration options
		-------------------------------------------
		caller_rate = caller_rate,

		-------------------------------------------
		-- UI Elements that interoperate between systems
		-------------------------------------------
		answer_button = nil,
		refuse_button = nil,
	}

	-- Instance the caller, player, text generator and cabin view
	obj.caller_window = { obj.win_x, obj.win_y, obj.win_w, obj.win_h - cabin_view_height }
	obj.caller = Caller:new(obj.caller_window)
	obj.player = Player2:new()
	obj.text = Text:new()
	obj.cabin_window = { obj.win_x, obj.win_y, obj.win_w, cabin_view_height }
	obj.cabin = CabinView:new(obj.cabin_window)
	
	-- Configure the anser/refuse buttons
	local box_x = obj.win_x + (obj.win_w - (caller_box_width + caller_box_border/2))
	local box_y = obj.win_y + (obj.win_h - caller_box_height)/2
	obj.answer_button = Button:new("Answer", box_x, box_y + caller_box_height, button_width, button_height, 'center')
	obj.refuse_button = Button:new("Refuse", box_x + caller_box_width - button_width, box_y + caller_box_height, button_width, button_height, 'center')
	obj.answer_button.visible = false
	obj.refuse_button.visible = false


	obj = setmetatable(obj, CallerGame)
	return obj
end

-- Update the state of the game
function CallerGame:update(dt)
	-- Update the caller state
	if self.caller.caller_id > 0 then
		self.caller:update(dt)
	else
		-- We've got a new caller, update the caller information
		if(math.random() <= self.caller_rate) then
			-- Create the caller
			self.caller:create()
			-- Set up the text
			self.text:updateText("caller", "waiting")
		end
	end
	-- Update the player state
	self.player:update(dt)

	-- Update the cabin state
	self.cabin:update(dt)
	
	
	
	-- elseif phone_state == "Caught" then
	-- 	self.answer_button.visible = false
	--	self.refuse_button.visible = false
end

-- Check the buttons for user input
function CallerGame:mousepressed(x, y, button) 

end

-- Draw the caller game pieces
function CallerGame:draw()
	lg.setScissor(self.win_x, self.win_y, self.win_w, self.win_h)
	lg.setColor(128,128,128,255)
	lg.rectangle('fill', self.win_x, self.win_y, self.win_w, self.win_h)

end

return CallerGame

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
local caller_rate = 0.005
local cabin_view_height = 400

-- Call states, enumerated
local enum_call_states = {
	"Hiding",
	"Using",
	"Talking",
	"OnHold",
	"Caught"
}

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
		-- State of the call
		call_state = "Hiding",

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
	local c_text = { 0, 0, 0 }
	local p_text = { 0, 0, 0 }
	obj.text = Text:new(c_text, p_text)
	obj.cabin_window = { obj.win_x, obj.win_y + obj.win_h - cabin_view_height, obj.win_w, cabin_view_height }
	obj.cabin = CabinView:new(obj.cabin_window)
	
	-- Configure the anser/refuse buttons
	local box_x = obj.win_x + (obj.win_w - (caller_box_width + caller_box_border/2))
	local box_y = obj.win_y + (obj.win_h - (cabin_view_height + caller_box_height))/2
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
			-- Send the text to the text generator
			self.text:switchCaller(self.caller:getText())
			-- Set up the text
			self.text:updateText("caller", "waiting")
			-- Turn on the answer/receive buttons
			self.answer_button.visible = true
			if self.call_state == "Using" then
				self.answer_button.enabled = true
			else
				self.answer_button.enabled = false
			end
			self.refuse_button.visible = true
			self.refuse_button.enabled = true
		end
	end
	-- Update the player state
	self.player:update(dt)

	-- Update the cabin state
	if self.cabin:update(dt, self.call_state) then
		self.call_state = "Caught"
	end

	-- Update the game state for being caught
	if self.call_state == "Caught" then
	 	self.answer_button.visible = false
		self.refuse_button.visible = false
		if self.cabin:blink(dt) == true then
			self.caller:disconnect()
			self.player.phones_left = self.player.phones_left - 1
			if self.player.phones_left == 0 then
				print ("Player 2 loses")
			end
			self.call_state = "Hiding"
		end
	end

	-- Update the text
	self.text:update(dt, self.call_state)
end

-- Check the buttons for user input
function CallerGame:mousepressed(x, y, button) 
	-- Check the cabin view for use/hide phone
	local new_state = self.cabin:mousepressed(x, y, button, self.call_state)
	if not (new_state == nil) then
		self.call_state = new_state
		if self.call_state == "Using" then
			self.answer_button.enabled = true
		end
	end

	-- Check the answer and reject buttons
	if self.call_state == "Using" and self.answer_button:check(x, y, button) then
		-- We're in game mode, trigger on the release
		if button == false then
			self.answer_button.visible = false
			self.refuse_button.visible = false
			-- Set the mode to talking
			self.call_state = "Talking"
			-- Update the text
			self.text:updateText("player", "intro")
			self.text:updateText("caller", "intro")
		end
	-- Lame, the player rejected the call
	elseif self.refuse_button:check(x, y, button) then
		self.caller.caller_id = 0
		if button == false then
			self.answer_button.visible = false
			self.refuse_button.visible = false
		end
	end
end

-- Draw the caller game pieces
function CallerGame:draw()
	-- Draw the grey background
	lg.setScissor(self.win_x, self.win_y, self.win_w, self.win_h)
	lg.setColor(80,80,80,255)
	lg.rectangle('fill', self.win_x, self.win_y, self.win_w, self.win_h)
	
	-- Draw the cabin view
	self.cabin:draw(self.call_state)

	-- Draw the caller view
	self.caller:draw(self.call_state, self.text)

	-- Draw the caller buttons
	lg.setScissor(self.win_x, self.win_y, self.win_w, self.win_h)
	self.answer_button:draw()
	self.refuse_button:draw()
	
	-- Draw the player interface
	self.player:draw(self.call_state)
end

return CallerGame

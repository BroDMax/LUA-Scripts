local frame_counter = 0
local max_global1 = 0
local max_global2 = 0
local graph1 = {}
local graph2 = {}
local graphCarpet = {}

local WIDTH = 320

COLOR_WHITE			= 0xFFFFFFFF
COLOR_RED			= 0xFFFF0000
COLOR_GREEN			= 0xFF00FF00
COLOR_YELLOW		= 0xFFFFFF00
COLOR_BACKGROUND	= 0xC0000E60

WORLD_CLOUD = 2
WORLD_WATER = 3

function foo()
	local count_players			= mainmemory.read_u8(0xFFD8)
	local speed_player1			= mainmemory.read_s16_be(0xA019)
	local speed_player2			= mainmemory.read_s16_be(0xA099)
	if count_players > 1 then
		WIDTH = 320 / 2
	else
		WIDTH = 320
	end
	local speed_magic_carpet	= mainmemory.read_s16_be(0x9059)
	local world					= mainmemory.read_s16_be(0xFFDA)
	local act_id				= mainmemory.read_s16_be(0xFFDC)
	
	if speed_player1 > max_global1 then
		max_global1 = speed_player1
	end
	if count_players > 1 and speed_player2 > max_global2 then
		max_global2 = speed_player2
	end

	gui.drawRectangle(0, 0, WIDTH, 50, COLOR_BACKGROUND, COLOR_BACKGROUND)
	if count_players > 1 then
		gui.drawRectangle(WIDTH, 0, WIDTH, 50, COLOR_BACKGROUND, COLOR_BACKGROUND)
		gui.drawLine(WIDTH, 0, WIDTH, 50, COLOR_WHITE)
	end

	graph1[frame_counter] = speed_player1
	if count_players > 1 then
		graph2[frame_counter] = speed_player2
	end
	graphCarpet[frame_counter] = speed_magic_carpet

	local pointer = frame_counter
	local max_local1 = 0
	local max_local2 = 0

	-- Уровень на ковре-самолете
	if world == WORLD_CLOUD and act_id == 0 then
		for i = WIDTH - 1, 0, -1 do
		
			if pointer == 0 then
				pointer = WIDTH
			end

			drawMagicCarpetSpeed(graphCarpet[pointer], i)

			pointer = pointer - 1
		end

	-- Уровень под водой
	elseif world == WORLD_WATER and (act_id == 0 or act_id == 2 or act_id == 6 or act_id == 3 or act_id == 10) then
		for i = WIDTH - 1, 0, -1 do
		
			if pointer == 0 then
				pointer = WIDTH
			end

			drawPlayer1Swiming(graph1[pointer], i)
			if count_players > 1 then
				drawPlayer2Swiming(graph2[pointer], i)
			end

			pointer = pointer - 1
		end

	-- Во всех остальных уровнях
	else
		for i = WIDTH - 1, 0, -1 do
		
			if pointer == 0 then
				pointer = WIDTH
			end

			if graph1[pointer] > max_local1 then
				max_local1 = graph1[pointer]
			end
			if count_players > 1 and graph2[pointer] > max_local2 then
				max_local2 = graph2[pointer]
			end

			drawPlayer1Speed(graph1[pointer], i)
			if count_players > 1 then
				drawPlayer2Speed(graph2[pointer], i)
			end

			pointer = pointer - 1
		end

		local screenWidth = client.screenwidth()
		if count_players > 1 then
			gui.text(screenWidth / 2 - 190, 0, "global max 1p: " .. max_global1)
			gui.text(screenWidth / 2 - 120, 15, "max 1p: " .. max_local1)
			gui.text(screenWidth / 2 - 160, 30, "Current 1p: " .. speed_player1)
			gui.text(screenWidth - 190, 0, "global max 2p: " .. max_global2)
			gui.text(screenWidth - 120, 15, "max 2p: " .. max_local2)
			gui.text(screenWidth - 160, 30, "Current 2p: " .. speed_player2)
		else
			gui.text(screenWidth - 190, 0, "global max 1p: " .. max_global1)
			gui.text(screenWidth - 120, 15, "max 1p: " .. max_local1)
			gui.text(screenWidth - 160, 30, "Current 1p: " .. speed_player1)
		end
	end
	
	-- Проверяем счетчик кадров
	
	if frame_counter > WIDTH then
		frame_counter = 0
	else
		frame_counter = frame_counter + 1
	end
end

function init()
	for i = 0, WIDTH do
		graph1[i] = 0
		graph2[i] = 0
	end

	for i = 0, WIDTH do
		graphCarpet[i] = 0
	end
end

function drawPlayer1Speed(value, x)
	if value < 0 then
		value = value * -1
	end

	local y = value / 32
	local color = COLOR_WHITE

	if value >= 1024 then
		color = COLOR_RED
	elseif value >= 512 then
		color = COLOR_GREEN
	elseif value >= 480 then
		color = COLOR_YELLOW
	end
	
	gui.drawPixel(x, 50 - y, color)
end

function drawPlayer2Speed(value, x)
	if value < 0 then
		value = value * -1
	end

	local y = value / 32
	local color = COLOR_WHITE

	if value >= 1024 then
		color = COLOR_RED
	elseif value >= 512 then
		color = COLOR_GREEN
	elseif value >= 480 then
		color = COLOR_YELLOW
	end
	
	gui.drawPixel(x + WIDTH, 50 - y, color)
end

function drawPlayer1Swiming(value, x)
	if value < 0 then
		value = value * -1
	end

	local y = value / 32
	local color = COLOR_WHITE

	if value > 288 then
		color = COLOR_RED
	elseif value == 288 then
		color = COLOR_GREEN
	end
	
	gui.drawPixel(x, 50 - y, color)
end

function drawPlayer2Swiming(value, x)
	if value < 0 then
		value = value * -1
	end

	local y = value / 32
	local color = COLOR_WHITE

	if value > 288 then
		color = COLOR_RED
	elseif value == 288 then
		color = COLOR_GREEN
	end
	
	gui.drawPixel(x + WIDTH, 50 - y, color)
end

function drawMagicCarpetSpeed(value, x)
	local y = value / 13
	local color = COLOR_WHITE

	if value > 624 then
		color = COLOR_RED
	elseif value == 624 then
		color = COLOR_GREEN
	end
	
	gui.drawPixel(x, 50 - y, color)
end

init()
while true do
	foo()
	emu.frameadvance()
end
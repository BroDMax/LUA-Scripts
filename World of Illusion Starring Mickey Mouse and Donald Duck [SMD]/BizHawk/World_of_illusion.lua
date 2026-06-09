local frame_counter = 0
local max_global = 0
local graph = {}
local graph2 = {}

WIDTH = 320

COLOR_WHITE			= 0xFFFFFFFF
COLOR_RED			= 0xFFFF0000
COLOR_GREEN			= 0xFF00FF00
COLOR_YELLOW		= 0xFFFFFF00
COLOR_BACKGROUND	= 0xC0000E60

WORLD_CLOUD = 2
WORLD_WATER = 3

function foo()

	local speed_player1			= mainmemory.read_s16_be(0xA019)
	local speed_magic_carpet	= mainmemory.read_s16_be(0x9059)
	local world					= mainmemory.read_s16_be(0xFFDA)
	local act_id				= mainmemory.read_s16_be(0xFFDC)
	
	if speed_player1 > max_global then
		max_global = speed_player1
	end

	gui.drawRectangle(0, 0, WIDTH, 50, COLOR_BACKGROUND, COLOR_BACKGROUND)

	graph[frame_counter] = speed_player1
	graph2[frame_counter] = speed_magic_carpet

	local pointer = frame_counter
	local max_local = 0

	-- Уровень на ковре-самолете
	if world == WORLD_CLOUD and act_id == 0 then
		for i = WIDTH - 1, 0, -1 do
		
			if pointer == 0 then
				pointer = WIDTH
			end

			drawMagicCarpetSpeed(graph2[pointer], i)

			pointer = pointer - 1
		end

	-- Уровень под водой
	elseif world == WORLD_WATER and (act_id == 0 or act_id == 2 or act_id == 6 or act_id == 3 or act_id == 10) then
		for i = WIDTH - 1, 0, -1 do
		
			if pointer == 0 then
				pointer = WIDTH
			end

			drawPlayer1Swiming(graph[pointer], i)

			pointer = pointer - 1
		end

	-- Во всех остальных уровнях
	else
		for i = WIDTH - 1, 0, -1 do
		
			if pointer == 0 then
				pointer = WIDTH
			end

			if graph[pointer] > max_local then
				max_local = graph[pointer]
			end

			drawPlayer1Speed(graph[pointer], i)

			pointer = pointer - 1
		end

		local screenWidth = client.screenwidth()
		gui.text(screenWidth - 160, 0, "global max: " .. max_global)
		gui.text(screenWidth - 90, 15, "max: " .. max_local)
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
		graph[i] = 0
	end

	for i = 0, WIDTH do
		graph2[i] = 0
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
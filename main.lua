-- general

local screenWidth, screenHeight = 400, 400

-- board

-- board compsed of points
-- each point has a north, south, east, and west line, which are drawn or un-drawn
-- to compute filled squares, each point measures the square to it's south-east

local masterBoard = {}

function love.load()

	love.window.setMode(screenWidth, screenHeight)
	initBoard(masterBoard, 10, 10)

end

function initBoard(board, hPoints, vPoints)

	board.points = 
	{
		h = hPoints,
		v = vPoints,
		r = 5
	}

	board.location = 
	{
		w = screenWidth - ((screenWidth / 100) * 10),
		h = screenHeight - ((screenHeight / 100) * 10)
	}

	board.location.x = (screenWidth / 2) - (board.location.w / 2)
	board.location.y = (screenHeight / 2) - (board.location.h / 2)

	board.graphics = 
	{
		pointColour = { 255, 255, 255 }
	}

end

function love.draw()

	drawBoard(masterBoard)

end

function drawBoard(board)

	love.graphics.setColor(board.graphics.pointColour)

	for pointX = 0, board.points.h - 1 do

		for pointY = 0, board.points.v - 1 do

			local cartesianX = board.location.x + ((board.location.w / (board.points.h - 1)) * pointX)
			local cartesianY = board.location.y + ((board.location.h / (board.points.v - 1)) * pointY)

			love.graphics.circle("fill", cartesianX, cartesianY, board.points.r, 4)

		end

	end

end
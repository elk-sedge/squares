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

	board.location = 
	{
		w = screenWidth - ((screenWidth / 100) * 10),
		h = screenHeight - ((screenHeight / 100) * 10)
	}

	board.location.x = (screenWidth / 2) - (board.location.w / 2)
	board.location.y = (screenHeight / 2) - (board.location.h / 2)

	board.points = {}

	local pointCount = 1

	for pointX = 0, hPoints - 1 do

		for pointY = 0, vPoints - 1 do

			local cartesianX = board.location.x + ((board.location.w / (hPoints - 1)) * pointX)
			local cartesianY = board.location.y + ((board.location.h / (vPoints - 1)) * pointY)

			board.points[pointCount] = 
			{
				x = pointX,
				y = pointY,
				n = false, e = false, s = false, w = false,
				cartesianX = cartesianX,
				cartesianY = cartesianY
			}

			pointCount = pointCount + 1

		end

	end

	board.graphics = 
	{
		pointSize = 5,
		pointSegments = 4,
		pointColour = { 255, 255, 255 },
		lineColour = { 100, 100, 100 }
	}

end

function love.draw()

	drawBoard(masterBoard)

end

function drawBoard(board)

	love.graphics.setColor(board.graphics.pointColour)

	for _, point in ipairs(board.points) do
			
		love.graphics.circle("fill", point.cartesianX, point.cartesianY, board.graphics.pointSize, board.graphics.pointSegments)

	end

end
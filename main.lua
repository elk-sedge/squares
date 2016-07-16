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

	board.hPoints, board.vPoints = hPoints, vPoints

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
		lineUndrawnColour = { 100, 100, 100 },
		lineDrawnColour = { 255, 0, 0 }
	}

	board.graphics.hLineLength = board.location.w / (hPoints - 1)
	board.graphics.vLineLength = board.location.h / (vPoints - 1)

end

function love.draw()

	drawBoard(masterBoard)

end

function drawBoard(board)

	for _, point in ipairs(board.points) do

		-- draw east lines
		if (point.x < board.hPoints - 1) then

			if (point.e) then
				love.graphics.setColor(board.graphics.lineDrawnColour)
			else
				love.graphics.setColor(board.graphics.lineUndrawnColour)
			end

			love.graphics.line(point.cartesianX, point.cartesianY, point.cartesianX + board.graphics.hLineLength, point.cartesianY)

		end

		-- draw south lines
		if (point.y < board.vPoints - 1) then

			if (point.s) then
				love.graphics.setColor(board.graphics.lineDrawnColour)
			else
				love.graphics.setColor(board.graphics.lineUndrawnColour)
			end

			love.graphics.line(point.cartesianX, point.cartesianY, point.cartesianX, point.cartesianY + board.graphics.vLineLength)

		end

		-- draw point
		love.graphics.setColor(board.graphics.pointColour)
		love.graphics.circle("fill", point.cartesianX, point.cartesianY, board.graphics.pointSize, board.graphics.pointSegments)

	end

end

function love.mousepressed(x, y)

	for _, point in pairs(masterBoard.points) do

		if (not point.e) then
			point.e = eastLineCollision(x, y, point.cartesianX, point.cartesianY)
		end

		if (not point.s) then
			point.s = southLineCollision(x, y, point.cartesianX, point.cartesianY)
		end

	end

end

function eastLineCollision(x, y, pointX, pointY)

	if (x > pointX) and (x < pointX + masterBoard.graphics.hLineLength) then

		local yOffset = y - pointY

		if (yOffset < 10 and yOffset > -10) then

			return true

		end

	end	

	return false

end

function southLineCollision(x, y, pointX, pointY)

	if (y > pointY) and (y < pointY + masterBoard.graphics.vLineLength) then

		local xOffset = x - pointX

		if (xOffset < 10 and xOffset > -10) then

			return true

		end

	end

	return false

end
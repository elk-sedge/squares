-- allow one line anywhere
-- allow multiple lines that complete squares

-- general
local screenWidth, screenHeight = 400, 400

-- board
local masterBoard = {}
local boardCanvas

-- players
local currentPlayer

function love.load()

	love.window.setMode(screenWidth, screenHeight)
	boardCanvas = love.graphics.newCanvas(screenWidth, screenHeight)
	currentPlayer = 1

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
				
				cartesianX = cartesianX,
				cartesianY = cartesianY,

				n = false, e = false, s = false, w = false,
				fillSquare = false
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
		lineDrawnColour = { 255, 255, 255 },
		squareColour = { 105, 214, 250 },
		playerColour = { 255, 255, 255 }
	}

	board.graphics.hLineLength = board.location.w / (hPoints - 1)
	board.graphics.vLineLength = board.location.h / (vPoints - 1)
	board.graphics.playerSize = ((board.graphics.hLineLength + board.graphics.vLineLength) / 2) / 6

	drawBoard(masterBoard)

end

function love.draw()	

	love.graphics.setColor(255, 255, 255)
	love.graphics.setBlendMode("alpha", "premultiplied")
	love.graphics.draw(boardCanvas)

end

function drawBoard(board)

	love.graphics.setCanvas(boardCanvas)
	love.graphics.clear()
	love.graphics.setBlendMode("alpha")

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

		-- draw square
		if (point.fillSquare) then 

			love.graphics.setColor(board.graphics.playerColour)

			local squareCenterX = point.cartesianX + (board.graphics.hLineLength / 2)
			local squareCenterY = point.cartesianY + (board.graphics.vLineLength / 2)

			love.graphics.circle("line", squareCenterX, squareCenterY, board.graphics.playerSize, 20)

			print(board.graphics.pointSize * 1.3)

		end

		-- draw point
		love.graphics.setColor(board.graphics.pointColour)
		love.graphics.circle("fill", point.cartesianX, point.cartesianY, board.graphics.pointSize, board.graphics.pointSegments)

	end

	love.graphics.setCanvas()

end

function love.mousepressed(x, y)

	updateLines(x, y)
	updateSquares()
	drawBoard(masterBoard)

end

function updateLines(x, y)

	local lineDrawn = false

	for _, point in ipairs(masterBoard.points) do

		if (not lineDrawn) then

			if (not point.e) then

				point.e = eastLineCollision(x, y, point.cartesianX, point.cartesianY)
				lineDrawn = point.e

			end

		end

		if (not lineDrawn) then

			if (not point.s) then

				point.s = southLineCollision(x, y, point.cartesianX, point.cartesianY)
				lineDrawn = point.s

			end

		end

	end

end

function eastLineCollision(x, y, pointX, pointY)

	if (not closeToPoint(x, y, pointX, pointY)) then

		if (x > pointX) and (x < pointX + masterBoard.graphics.hLineLength) then

			local yOffset = y - pointY

			if (yOffset < 10 and yOffset > -10) then

				return true

			end

		end	

	end

	return false

end

function southLineCollision(x, y, pointX, pointY)

	if (not closeToPoint(x, y, pointX, pointY)) then

		if (y > pointY) and (y < pointY + masterBoard.graphics.vLineLength) then

			local xOffset = x - pointX

			if (xOffset < 10 and xOffset > -10) then

				return true

			end

		end

	end

	return false

end

function closeToPoint(x, y, pointX, pointY)

	if (x > pointX - 10 and x < pointX + 10) then

		if (y > pointY - 10 and y < pointY + 10) then

			return true

		end

	end

	return false

end

function updateSquares()

	for pointIndex, point in ipairs(masterBoard.points) do

		-- if point.e and point.s, get index of east and south points
		if (point.e and point.s) then

			local relativeEastPoint = masterBoard.points[pointIndex + masterBoard.vPoints]
			local relativeSouthPoint = masterBoard.points[pointIndex + 1]

			-- if east.s and south.e, square completed
			if (relativeEastPoint.s and relativeSouthPoint.e) then

				point.fillSquare = true

			end

		end

	end

end

function love.keypressed(key)

	if (key == "space") then

		if currentPlayer == 1 then currentPlayer = 2 elseif currentPlayer == 2 then currentPlayer = 1 end

	end

end
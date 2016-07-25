-- allow one line anywhere
-- allow multiple lines that complete squares

-- general
local screenWidth, screenHeight = 600, 450 -- 4:3

-- board
local boardWidth, boardHeight = math.ceil(screenWidth / 1.65), math.ceil(screenWidth / 1.65)
local masterBoard = {}
local boardCanvas

-- players
local currentPlayer

-- UI
local uiCanvas

function love.load()

	love.window.setMode(screenWidth, screenHeight)
	boardCanvas = love.graphics.newCanvas(boardWidth, boardHeight)
	uiCanvas = love.graphics.newCanvas(screenWidth, screenHeight)

	initBoard(masterBoard, 10, 10, boardWidth, boardHeight)
	currentPlayer = 1

end

function initBoard(board, hPoints, vPoints, boardWidth, boardHeight)

	board.hPoints, board.vPoints = hPoints, vPoints

	board.graphics = 
	{
		pointSegments = 4,
		pointColour = { 255, 255, 255 },
		lineUndrawnColour = { 100, 100, 100 },
		lineDrawnColour = { 255, 255, 255 },
		lineHighlightColour = { 0, 255, 0 },
		squareColour = { 105, 214, 250 },
		playerColour = { 255, 255, 255 }
	}

	board.dimensions = {}

	board.dimensions.w = boardWidth
	board.dimensions.h = boardHeight

	board.dimensions.x = (screenWidth / 2) - (board.dimensions.w / 2)
	board.dimensions.y = (screenHeight / 2) - (board.dimensions.h / 2)

	board.dimensions.hLineLength = board.dimensions.w / (hPoints - 1)
	board.dimensions.vLineLength = board.dimensions.h / (vPoints - 1)

	board.dimensions.pointSize = 5
	board.dimensions.pointW = boardWidth - (board.dimensions.pointSize * 2)
	board.dimensions.pointH = boardHeight - (board.dimensions.pointSize * 2)

	board.dimensions.playerSize = ((board.dimensions.hLineLength + board.dimensions.vLineLength) / 2) / 6

	board.points = {}

	local pointCount = 1

	for pointX = 0, hPoints - 1 do

		for pointY = 0, vPoints - 1 do

			local cartesianX = board.dimensions.pointSize + (board.dimensions.pointW / (hPoints - 1)) * pointX
			local cartesianY = board.dimensions.pointSize + (board.dimensions.pointH / (vPoints - 1)) * pointY

			board.points[pointCount] = 
			{
				index = pointCount,

				x = pointX,
				y = pointY,
				
				cartesianX = cartesianX,
				cartesianY = cartesianY,

				n = false, e = false, s = false, w = false,
				nh = false, eh = false, sh = false, wh = false,
				fillSquare = false,
				player = nil
			}

			pointCount = pointCount + 1

		end

	end

	drawBoard(masterBoard)

end

function love.draw()	

	love.graphics.setColor(255, 255, 255)
	love.graphics.setBlendMode("alpha", "premultiplied")
	love.graphics.draw(boardCanvas, masterBoard.dimensions.x, masterBoard.dimensions.y)

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
			elseif (point.eh) then
				love.graphics.setColor(board.graphics.lineHighlightColour)
			else
				love.graphics.setColor(board.graphics.lineUndrawnColour)
			end

			love.graphics.line(point.cartesianX, point.cartesianY, point.cartesianX + board.dimensions.hLineLength, point.cartesianY)

		end

		-- draw south lines
		if (point.y < board.vPoints - 1) then

			if (point.s) then
				love.graphics.setColor(board.graphics.lineDrawnColour)
			elseif (point.sh) then
				love.graphics.setColor(board.graphics.lineHighlightColour)		
			else
				love.graphics.setColor(board.graphics.lineUndrawnColour)
			end

			love.graphics.line(point.cartesianX, point.cartesianY, point.cartesianX, point.cartesianY + board.dimensions.vLineLength)

		end

		-- draw square
		if (point.fillSquare) then 

			local squareCenterX = point.cartesianX + (board.dimensions.hLineLength / 2)
			local squareCenterY = point.cartesianY + (board.dimensions.vLineLength / 2)

			if (point.player == 1) then

				love.graphics.circle("line", squareCenterX, squareCenterY, board.dimensions.playerSize, 20)

			elseif (point.player == 2) then

				local squareSize = board.dimensions.playerSize * 2

				love.graphics.rectangle("line", squareCenterX - (squareSize / 2), squareCenterY - (squareSize / 2), 
					squareSize, squareSize)

			end

		end

		-- draw point
		love.graphics.setColor(board.graphics.pointColour)
		love.graphics.circle("fill", point.cartesianX, point.cartesianY, board.dimensions.pointSize, board.graphics.pointSegments)

	end

	love.graphics.setCanvas()

end

function love.mousemoved(x, y)

	local relativeX = x - masterBoard.dimensions.x
	local relativeY = y - masterBoard.dimensions.y

	highlightLine(masterBoard, relativeX, relativeY)
	drawBoard(masterBoard)

end

function love.mousepressed(x, y)

	local relativeX = x - masterBoard.dimensions.x
	local relativeY = y - masterBoard.dimensions.y

	updateLines(masterBoard, relativeX, relativeY)
	updateSquares()
	drawBoard(masterBoard)

end

function highlightLine(board, x, y)

	for _, point in pairs(board.points) do

		point.eh, point.sh = false, false

	end

	for _, point in ipairs(board.points) do

		if (not point.e and not point.eh) then

			point.eh = eastLineCollision(board, point, x, y)

		end

		if (not point.s and not point.sh) then

			point.sh = southLineCollision(board, point, x, y)

		end

		if (point.eh or point.sh) then

			break

		end

	end

end

function updateLines(board, x, y)

	local lineDrawn = false

	for _, point in ipairs(board.points) do

		if (not lineDrawn) then

			if (not point.e) then

				point.e = eastLineCollision(board, point, x, y)
				lineDrawn = point.e

			end

		end

		if (not lineDrawn) then

			if (not point.s) then

				point.s = southLineCollision(board, point, x, y)
				lineDrawn = point.s

			end

		end

	end

end

function eastLineCollision(board, point, x, y)

	if (not closeToAdjacentPoints(board, point, "east", x, y)) then

		if (x > point.cartesianX) and (x < point.cartesianX + board.dimensions.hLineLength) then

			local yOffset = y - point.cartesianY

			if (yOffset < 10 and yOffset > -10) then

				return true

			end

		end	

	end

	return false

end

function southLineCollision(board, point, x, y)

	if (not closeToAdjacentPoints(board, point, "south", x, y)) then

		if (y > point.cartesianY) and (y < point.cartesianY + board.dimensions.vLineLength) then

			local xOffset = x - point.cartesianX

			if (xOffset < 10 and xOffset > -10) then

				return true

			end

		end

	end

	return false

end

function closeToAdjacentPoints(board, point, direction, x, y)

	if (closeToPoint(point, x, y)) then

		return true

	end

	if (direction == "east") then

		local eastPoint = getEastPoint(board, point)

		if (eastPoint) then

			if (closeToPoint(eastPoint, x, y)) then

				return true

			end

		end

	elseif (direction == "south") then

		local southPoint = getSouthPoint(board, point)

		if (southPoint) then

			if (closeToPoint(southPoint, x, y)) then

				return true

			end

		end

	end

	return false

end

function getEastPoint(board, point)

	return board.points[point.index + board.vPoints]

end

function getSouthPoint(board, point)

	return board.points[point.index + 1]

end

function closeToPoint(point, x, y) 

	local distance = 15

	if (x > point.cartesianX - distance and x < point.cartesianX + distance) then

		if (y > point.cartesianY - distance and y < point.cartesianY + distance) then

			return true

		end

	end

end

function updateSquares()

	for pointIndex, point in ipairs(masterBoard.points) do

		-- if point.e and point.s, get index of east and south points
		if (point.e and point.s) then

			local relativeEastPoint = masterBoard.points[pointIndex + masterBoard.vPoints]
			local relativeSouthPoint = masterBoard.points[pointIndex + 1]

			if (relativeEastPoint and relativeSouthPoint) then

				-- if east.s and south.e, square completed
				if (relativeEastPoint.s and relativeSouthPoint.e) then

					if (not point.fillSquare) then

						point.fillSquare = true
						point.player = currentPlayer

					end

				end

			end

		end

	end

end

function love.keypressed(key)

	if (key == "space") then

		if currentPlayer == 1 then currentPlayer = 2 elseif currentPlayer == 2 then currentPlayer = 1 end

	end

end
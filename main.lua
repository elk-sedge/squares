-- ************************************************ HELPERS

function round(x)

	local mult = 10^(0)
	return math.floor(x * mult + 0.5) / mult

end

-- ************************************************ GLOBAL

local screenWidth, screenHeight = 600, 450 -- 4:3
local boardWidth, boardHeight = round(screenWidth / 1.65), round(screenWidth / 1.65)

local masterBoard = {}
local masterUI = {}
local masterGameData = {}

local boardCanvas
local uiCanvas

-- ************************************************ MAIN

function love.load()

	love.window.setMode(screenWidth, screenHeight)

	boardCanvas = love.graphics.newCanvas(boardWidth, boardHeight)
	uiCanvas = love.graphics.newCanvas(screenWidth, screenHeight)

	initGameData(masterGameData)
	initBoard(masterBoard, 10, 10, boardWidth, boardHeight)
	initUI(masterUI, screenWidth, screenHeight)

	randomisedStart(masterBoard, 75)

end

function initBoard(board, hPoints, vPoints, boardWidth, boardHeight)

	board.hPoints, board.vPoints = hPoints, vPoints

	board.graphics = 
	{
		pointSegments = 4,
		pointColour = { 255, 255, 255 },
		lineUndrawnColour = { 100, 100, 100 },
		lineDrawnColour = { 255, 255, 255 },
		lineHighlightColour = { 0, 255, 255 },
		squareColour = { 105, 214, 250 },
		playerColour = { 255, 255, 255 },
		font = love.graphics.newFont("Early GameBoy.ttf", 16)
	}

	board.dimensions = {}

	board.dimensions.w = boardWidth
	board.dimensions.h = boardHeight

	board.dimensions.x = (screenWidth / 2) - (board.dimensions.w / 2)
	board.dimensions.y = (screenHeight / 2) - (board.dimensions.h / 2)

	board.dimensions.hLineLength = round(board.dimensions.w / (hPoints - 1))
	board.dimensions.vLineLength = round(board.dimensions.h / (vPoints - 1))

	board.dimensions.pointSize = 5
	board.dimensions.pointW = boardWidth - (board.dimensions.pointSize * 2)
	board.dimensions.pointH = boardHeight - (board.dimensions.pointSize * 2)

	board.dimensions.textWidth = board.graphics.font:getWidth("X")
	board.dimensions.textHeight = board.graphics.font:getHeight("X")

	board.points = {}

	local pointCount = 1

	for pointX = 0, hPoints - 1 do

		for pointY = 0, vPoints - 1 do

			local cartesianX = round(board.dimensions.pointSize + (board.dimensions.pointW / (hPoints - 1)) * pointX)
			local cartesianY = round(board.dimensions.pointSize + (board.dimensions.pointH / (vPoints - 1)) * pointY)

			board.points[pointCount] = 
			{
				index = pointCount,

				x = pointX,
				y = pointY,
				
				cartesianX = cartesianX,
				cartesianY = cartesianY,

				e = false, s = false, 
				eh = false, sh = false, 
				fillSquare = false,
				player = nil
			}

			pointCount = pointCount + 1

		end

	end

	drawBoard(masterBoard, masterGameData)

end

function initUI(UI, uiWidth, uiHeight)

	UI.graphics = 
	{
		font = love.graphics.newFont("Early GameBoy.ttf", 24),
		fontColour = { 255, 255, 255 },
		fontHighlightColour = { 0, 255, 255 }
	}

	UI.dimensions = {}

	UI.dimensions.w = uiWidth
	UI.dimensions.h = uiHeight

	UI.dimensions.textHeight = UI.graphics.font:getHeight("X")
	UI.dimensions.sigilWidth = UI.graphics.font:getWidth("X")
	UI.dimensions.scoreWidthSingle = UI.graphics.font:getWidth("0")
	UI.dimensions.scoreWidthDouble = UI.graphics.font:getWidth("00")
	UI.dimensions.spacing = 20

	UI.dimensions.playerOneSigilx = (masterBoard.dimensions.x / 2) - (UI.dimensions.sigilWidth / 2)
	UI.dimensions.playerOneScoreSinglex = (masterBoard.dimensions.x / 2) - (UI.dimensions.scoreWidthSingle / 2)
	UI.dimensions.playerOneScoreDoublex = (masterBoard.dimensions.x / 2) - (UI.dimensions.scoreWidthDouble / 2)

	UI.dimensions.playerTwoSigilx = (masterBoard.dimensions.x + masterBoard.dimensions.w) + (masterBoard.dimensions.x / 2) - (UI.dimensions.sigilWidth / 2)
	UI.dimensions.playerTwoScoreSinglex = (masterBoard.dimensions.x + masterBoard.dimensions.w) + (masterBoard.dimensions.x / 2) - (UI.dimensions.scoreWidthSingle / 2)
	UI.dimensions.playerTwoScoreDoublex = (masterBoard.dimensions.x + masterBoard.dimensions.w) + (masterBoard.dimensions.x / 2) - (UI.dimensions.scoreWidthDouble / 2)

	UI.dimensions.sigilY = (screenHeight / 2) - (UI.dimensions.textHeight + UI.dimensions.spacing)
	UI.dimensions.scoreY = (screenHeight / 2) + UI.dimensions.spacing

	drawUI(masterUI, masterGameData)

end

function initGameData(gameData)

	gameData["playerOne"] = 
	{
		score = 0,
		completedSquare = false,
		lineDrawn = false,
		sigil = "X"
	}

	gameData["playerTwo"] = 
	{
		score = 0,
		completedSquare = false,
		lineDrawn = false,
		sigil = "0"
	}

	gameData.currentPlayer = gameData["playerOne"]

end

function randomisedStart(board, randomLineQuantity) 

	local randomLines = {}
	local directions = { "e", "s" }

	math.randomseed(os.time())

	for i = 1, randomLineQuantity do

		local randomLine

		repeat

			local randomPoint = math.random(#board.points)
			local randomDirection = directions[math.random(#directions)]

			randomLine = { point = randomPoint, direction = randomDirection }

		until lineIsLegitimate(board, randomLine) and not lineListContainsLine(randomLines, randomLine) and not lineMakesSquarePossible(board, randomLines, randomLine)

		table.insert(randomLines, randomLine)

	end

	for _, randomLine in pairs(randomLines) do

		local point = board.points[randomLine.point]

		if (randomLine.direction == "e") then

			point.e = true

		end

		if (randomLine.direction == "s") then

			point.s = true

		end

	end

	drawBoard(board, masterGameData)

end

function lineIsLegitimate(board, line)

	if (pointIsOnRightCol(line.point, #board.points, board.vPoints) and line.direction == "e") then

		return false

	end

	if (pointIsOnBottomRow(line.point, board.vPoints) and line.direction == "s") then

		return false

	end

	return true

end

function lineMakesSquarePossible(board, lines, potLine)

	if (potLine.direction == "e") then

		if (not pointIsOnTopRow(potLine.point, board.vPoints)) then

			local northPointEast, northPointSouth, northEastPointSouth = getEastNorthSquareLines(potLine.point, board.vPoints)

			local northPointEastDrawn = lineListContainsLine(lines, northPointEast) and 1 or 0
			local northPointSouthDrawn = lineListContainsLine(lines, northPointSouth) and 1 or 0
			local northEastPointSouthDrawn = lineListContainsLine(lines, northEastPointSouth) and 1 or 0

			local totalLines = northPointEastDrawn + northPointSouthDrawn + northEastPointSouthDrawn

			if (totalLines > 1) then

				return true

			end

		end

		if (not pointIsOnBottomRow(potLine.point, board.vPoints)) then

			local localPointSouth, eastPointSouth, southPointEast = getEastSouthSquareLines(potLine.point, board.vPoints)

			local localPointSouthDrawn = lineListContainsLine(lines, localPointSouth) and 1 or 0
			local eastPointSouthDrawn = lineListContainsLine(lines, eastPointSouth) and 1 or 0
			local southPointEastDrawn = lineListContainsLine(lines, southPointEast) and 1 or 0

			local totalLines = localPointSouthDrawn + eastPointSouthDrawn + southPointEastDrawn

			if (totalLines > 1) then

				return true

			end

		end

	elseif (potLine.direction == "s") then

		if (not pointIsOnLeftCol(potLine.point, board.vPoints)) then

			local westPointEast, westPointSouth, southWestPointEast = getSouthWestSquareLines(potLine.point, board.vPoints)

			local westPointEastDrawn = lineListContainsLine(lines, westPointEast) and 1 or 0
			local westPointSouthDrawn = lineListContainsLine(lines, westPointSouth) and 1 or 0
			local southWestPointEastDrawn = lineListContainsLine(lines, southWestPointEast) and 1 or 0

			local totalLines = westPointEastDrawn + westPointSouthDrawn + southWestPointEastDrawn

			if (totalLines > 1) then

				return true

			end

		end

		if not (pointIsOnRightCol(potLine.point, #board.points, board.vPoints)) then

			local localPointEast, eastPointSouth, southPointEast = getSouthEastSquareLines(potLine.point, board.vPoints)

			local localPointEastDrawn = lineListContainsLine(lines, localPointEast) and 1 or 0
			local eastPointSouthDrawn = lineListContainsLine(lines, eastPointSouth) and 1 or 0
			local southPointEastDrawn = lineListContainsLine(lines, southPointEast) and 1 or 0

			local totalLines = localPointEastDrawn + eastPointSouthDrawn + southPointEastDrawn

			if (totalLines > 1) then

				return true

			end

		end

	end

	return false

end

function pointIsOnTopRow(point, vPoints)

	return point == 1 or point % (vPoints + 1) == 0

end

function pointIsOnBottomRow(point, vPoints)

	return point % vPoints == 0

end

function pointIsOnLeftCol(point, vPoints)

	return point <= vPoints

end

function pointIsOnRightCol(point, totalPoints, vPoints)

	return point > totalPoints - vPoints

end

function getEastNorthSquareLines(point, vPoints)

	-- get northPointEast/northPointSouth/northEastPointSouth
	local northPointEast = { point = point - 1, direction = "e" }
	local northPointSouth = { point = point - 1, direction = "s" }
	local northEastPointSouth = { point = point + (vPoints - 1), direction = "s" }

	return northPointEast, northPointSouth, northEastPointSouth

end

function getEastSouthSquareLines(point, vPoints)

	-- get localPointSouth/eastPointSouth/southPointEast
	local localPointSouth = { point = point, direction = "s" }
	local eastPointSouth = { point = point + vPoints, direction = "s" }
	local southPointEast = { point = point + 1, direction = "e" }

	return localPointSouth, eastPointSouth, southPointEast

end

function getSouthWestSquareLines(point, vPoints)

	-- get eastPointEast/eastPointSouth/southEastPointEast
	local westPointEast = { point = point - vPoints, direction = "e" }
	local westPointSouth = { point = point - vPoints, direction = "s" }
	local southWestPointEast = { point = point - (vPoints - 1), direction = "e" }

	return westPointEast, westPointSouth, southWestPointEast

end

function getSouthEastSquareLines(point, vPoints)

	-- get localPointEast, eastPointSouth, southPointEast
	local localPointEast = { point = point, direction = "e" }
	local eastPointSouth = { point = point + 10, direction = "s" }
	local southPointEast = { point = point + 1, direction = "e" }

	return localPointEast, eastPointSouth, southPointEast

end

function lineListContainsLine(lines, line)

	for _, lineListLine in pairs(lines) do

		if (line.point == lineListLine.point) then

			if (line.direction == lineListLine.direction) then

				return true

			end

		end

	end

	return false

end

function love.draw()	

	love.graphics.setColor(255, 255, 255)
	love.graphics.setBlendMode("alpha", "premultiplied")

	love.graphics.draw(uiCanvas, 0, 0)
	love.graphics.draw(boardCanvas, masterBoard.dimensions.x, masterBoard.dimensions.y)

end

function drawBoard(board, gameData)

	love.graphics.setCanvas(boardCanvas)
	love.graphics.clear()
	love.graphics.setBlendMode("alpha")

	for _, point in ipairs(board.points) do

		-- draw east lines
		if (point.x < board.hPoints - 1) then

			if (point.e) then
				love.graphics.setLineWidth(2)
				love.graphics.setColor(board.graphics.lineDrawnColour)
			elseif (point.eh) then
				love.graphics.setLineWidth(2)
				love.graphics.setColor(board.graphics.lineHighlightColour)
			else
				love.graphics.setLineWidth(1)
				love.graphics.setColor(board.graphics.lineUndrawnColour)
			end

			love.graphics.line(point.cartesianX, point.cartesianY, point.cartesianX + board.dimensions.hLineLength, point.cartesianY)

		end

		-- draw south lines
		if (point.y < board.vPoints - 1) then

			if (point.s) then
				love.graphics.setLineWidth(2)
				love.graphics.setColor(board.graphics.lineDrawnColour)
			elseif (point.sh) then
				love.graphics.setLineWidth(2)
				love.graphics.setColor(board.graphics.lineHighlightColour)		
			else
				love.graphics.setLineWidth(1)
				love.graphics.setColor(board.graphics.lineUndrawnColour)
			end

			love.graphics.line(point.cartesianX, point.cartesianY, point.cartesianX, point.cartesianY + board.dimensions.vLineLength)

		end

		-- draw square
		if (point.fillSquare) then 

			love.graphics.setFont(board.graphics.font)

			local squareCenterX = point.cartesianX + (board.dimensions.hLineLength / 2)
			local squareCenterY = point.cartesianY + (board.dimensions.vLineLength / 2)

			local textX = round(squareCenterX - (masterBoard.dimensions.textWidth / 2))
			local textY = round(squareCenterY - (masterBoard.dimensions.textHeight / 2))

			if (point.player == gameData["playerOne"]) then
				love.graphics.print(gameData["playerOne"].sigil, textX, textY)
			elseif (point.player == gameData["playerTwo"]) then
				love.graphics.print(gameData["playerTwo"].sigil, textX, textY)
			end

		end

		-- draw point
		love.graphics.setColor(board.graphics.pointColour)
		love.graphics.circle("fill", point.cartesianX, point.cartesianY, board.dimensions.pointSize, board.graphics.pointSegments)

	end

	love.graphics.setCanvas()

end

function drawUI(ui, gameData)

	love.graphics.setCanvas(uiCanvas)
	love.graphics.clear()
	love.graphics.setBlendMode("alpha")

	love.graphics.setFont(ui.graphics.font)

	-- set player one colour
	love.graphics.setColor(ui.graphics.fontColour)
	if (gameData.currentPlayer == gameData["playerOne"]) then love.graphics.setColor(ui.graphics.fontHighlightColour) end

	-- print player one sigil
	love.graphics.print(gameData["playerOne"].sigil, ui.dimensions.playerOneSigilx, ui.dimensions.sigilY, 0)

	-- print player one score
	local playerOneScore = gameData["playerOne"].score

	if (playerOneScore < 10) then
		love.graphics.print(tostring(gameData["playerOne"].score), ui.dimensions.playerOneScoreSinglex, ui.dimensions.scoreY, 0)
	else
		love.graphics.print(tostring(gameData["playerOne"].score), ui.dimensions.playerOneScoreDoublex, ui.dimensions.scoreY, 0)
	end

	-- set player two colour
	love.graphics.setColor(ui.graphics.fontColour)
	if (gameData.currentPlayer == gameData["playerTwo"]) then love.graphics.setColor(ui.graphics.fontHighlightColour) end

	-- print player two sigil
	love.graphics.print(gameData["playerTwo"].sigil, ui.dimensions.playerTwoSigilx, ui.dimensions.sigilY, 0)

	-- print player two score
	local playerTwoScore = gameData["playerTwo"].score
	if (playerTwoScore < 10) then
		love.graphics.print(tostring(gameData["playerTwo"].score), ui.dimensions.playerTwoScoreSinglex, ui.dimensions.scoreY, 0)
	else
		love.graphics.print(tostring(gameData["playerTwo"].score), ui.dimensions.playerTwoScoreDoublex, ui.dimensions.scoreY, 0)
	end

	love.graphics.setCanvas()

end

function love.mousemoved(x, y)

	local relativeX = x - masterBoard.dimensions.x
	local relativeY = y - masterBoard.dimensions.y

	highlightLine(masterBoard, relativeX, relativeY)
	drawBoard(masterBoard, masterGameData)

end

function love.mousepressed(x, y)

	local relativeX = x - masterBoard.dimensions.x
	local relativeY = y - masterBoard.dimensions.y

	updateLines(masterBoard, relativeX, relativeY)
	updateSquares(masterBoard, masterGameData)

	drawBoard(masterBoard, masterGameData)
	drawUI(masterUI, masterGameData)

	if (masterGameData.currentPlayer.lineDrawn) then

		completeMove(masterGameData, masterUI)

	end

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
				masterGameData.currentPlayer.lineDrawn = lineDrawn

			end

		end

		if (not lineDrawn) then

			if (not point.s) then

				point.s = southLineCollision(board, point, x, y)
				lineDrawn = point.s
				masterGameData.currentPlayer.lineDrawn = lineDrawn

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

function updateSquares(board, gameData)

	gameData.currentPlayer.completedSquare = false

	for pointIndex, point in ipairs(board.points) do

		-- if point.e and point.s, get index of east and south points
		if (point.e and point.s) then

			local relativeEastPoint = board.points[pointIndex + board.vPoints]
			local relativeSouthPoint = board.points[pointIndex + 1]

			if (relativeEastPoint and relativeSouthPoint) then

				-- if east.s and south.e, square completed
				if (relativeEastPoint.s and relativeSouthPoint.e) then

					if (not point.fillSquare) then

						point.fillSquare = true
						point.player = gameData.currentPlayer
						updateScore(gameData)

					end

				end

			end

		end

	end

end

function updateScore(gameData)

	gameData.currentPlayer.score = gameData.currentPlayer.score + 1
	gameData.currentPlayer.completedSquare = true

end

function completeMove(gameData, ui)

	if (not gameData.currentPlayer.completedSquare) then

		if (gameData.currentPlayer.lineDrawn) then

			switchPlayer(gameData, ui)

		end

	end

end

function switchPlayer(gameData, ui)

	if (gameData.currentPlayer == gameData["playerOne"]) then

		gameData.currentPlayer = gameData["playerTwo"]

	elseif (gameData.currentPlayer == gameData["playerTwo"]) then

		gameData.currentPlayer = gameData["playerOne"]

	end

	gameData.currentPlayer.lineDrawn = false
	gameData.currentPlayer.completedSquare = false

	drawUI(ui, gameData)

end

// globals
waterLocation = []
wellLocation = []
seletectedWaterLocation = []
waitTime = 0.0001 // in seconds
numOfLoopToWait = 10
clearMode = "debris"

//**********************************************
me.till = function
    me.select "Hoe"
    me.useTool
end function
//**********************************************
me.water = function
    me.select "Watering Can"
    me.useTool
end function
//**********************************************
me.plant = function(seedName)
    me.select seedName
    me.placeItem
end function
//**********************************************
me.twohead = function
    if me.facing == 0 then       //north
        x = me.position.x
		y = me.position.y-2
    else if me.facing == 1 then  //east
        x = me.position.x+2
		y = me.position.y              
    else if me.facing == 2 then  //south
        x = me.position.x
		y = me.position.y+2          
    else if me.facing == 3 then  //west
        x = me.position.x-2
		y = me.position.y
    end if
	return farm.tile(x,y)
end function
//**********************************************
me.turnNorth = function
    //direction bot is facing: 0=north, 1=east, 2=south, 3=west
    if me.facing == 0 then       //north
        //do nothing            
    else if me.facing == 1 then  //east
        me.left                 
    else if me.facing == 2 then  //south
        me.right                 
        me.right                
    else if me.facing == 3 then  //west
        me.right
    end if
end function
//**********************************************
me.turnEast = function
    //direction bot is facing: 0=north, 1=east, 2=south, 3=west
    if me.facing == 0 then      //north
        me.right               
    else if me.facing == 1 then //east
        //do nothing           
    else if me.facing == 2 then //south
        me.left                
    else if me.facing == 3 then //west
        me.right
        me.right
    end if
end function
//**********************************************
me.turnSouth = function
    //direction bot is facing: 0=north, 1=east, 2=south, 3=west
    if me.facing == 0 then      //north
        me.right
        me.right
    else if me.facing == 1 then //east
        me.right
    else if me.facing == 2 then //south
        //do nothing
    else if me.facing == 3 then //west
        me.left
    end if
end function
//**********************************************
me.turnWest = function
    //direction bot is facing: 0=north, 1=east, 2=south, 3=west
    if me.facing == 0 then      //north
        me.left
    else if me.facing == 1 then //east
        me.right
        me.right
    else if me.facing == 2 then //south
        me.right
    else if me.facing == 3 then //west
        //do nothing
    end if
end function
//**********************************************
me.moveToNextAvailableTile = function
	//check west
	if farm.tile(me.position.x-1,me.position.y)==null then // tile is empty
		me.turnWest
		me.forward
		return
	else if farm.tile(me.position.x-1,me.position.y).hasIndex("passable") then 
		if farm.tile(me.position.x-1,me.position.y).passable == 1 then // tile is not empty but passable
			me.turnWest
			me.forward
			return
		end if
	end if
	//check north
	if farm.tile(me.position.x,me.position.y-1)==null then // tile is empty
		me.turnNorth
		me.forward
		return
	else if farm.tile(me.position.x,me.position.y-1).hasIndex("passable") then 
		if farm.tile(me.position.x,me.position.y-1).passable == 1 then // tile is not empty but passable
			me.turnNorth
			me.forward
			return
		end if
	end if
	//check east
	if farm.tile(me.position.x+1,me.position.y)==null then // tile is empty
		me.turnEast
		me.forward
		return
	else if farm.tile(me.position.x+1,me.position.y).hasIndex("passable") then 
		if farm.tile(me.position.x+1,me.position.y).passable == 1 then // tile is not empty but passable
			me.turnEast
			me.forward
			return
		end if
	end if
	//check south
	if farm.tile(me.position.x,me.position.y+1)==null then // tile is empty
		me.turnSouth
		me.forward
		return
	else if farm.tile(me.position.x,me.position.y+1).hasIndex("passable") then 
		if farm.tile(me.position.x,me.position.y+1).passable == 1 then // tile is not empty but passable
			me.turnSouth
			me.forward
			return
		end if
	end if
end function
//**********************************************
me.goto = function(x,y)
    stepx = me.position.x - x
    stepy = me.position.y - y
    
    if stepx>0 then
        dirx = "left"
    else
        dirx = "right"
    end if
    
    if stepy>0 then
        diry = "up"
    else
        diry = "down"
    end if
    
    stepx = abs(stepx)
    stepy = abs(stepy)
    
    while stepx>0 or stepy>0
		wait(0.01)
        if stepx>0 then
            if dirx == "left" then
                me.turnWest
            else
                me.turnEast
            end if
            me.forward
            stepx = stepx - 1
        end if
        if stepy>0 then
            if diry == "up" then
                me.turnNorth
            else
                me.turnSouth
            end if
            me.forward
            stepy = stepy - 1
        end if
    end while
end function

//**********************************************
neighbors = function (coordinate)
    neighbors = []
    neighbors.push([coordinate[0],coordinate[1]-1]) //north
    neighbors.push([coordinate[0]+1,coordinate[1]]) //east
    neighbors.push([coordinate[0],coordinate[1]+1]) //south
    neighbors.push([coordinate[0]-1,coordinate[1]]) //west
    return neighbors
end function
//**********************************************************************************
// uses Breadth First Search Algorithm to search for tile. Returns path to tile. Resource intensive if area is large
// reference: https://www.redblobgames.com/pathfinding/tower-defense/#diagram-parents
// Example usage, searchFor("dry",0, 100, startingLocation), searchFor("name","Parsnip", 1000), etc.
// If startPos is not entered, starting location will be at BOT location
// - tileToLookFor = "waterSource" is a special use case to find all water sources (well, pond, river, etc).
// - tileParameter is ignored when tileToLookFor = "waterSource"
// - numTilesToSearch specify how many tiles to search. If not used, then defauts to 500 tiles
// - locationOnly when 1 returns only the location, when 0 returns the full path
searchForTile = function(tileToLookFor, tileParameter, numTilesToSearch, locationOnly, startPos)
	if tileParameter == null then
		tileParameter = "something"
	end if
	if numTilesToSearch == null then 
		searchLimit = 500
	else
		searchLimit = numTilesToSearch
	end if
	if startPos != null then
		startNode = startPos
	else
		startNode = [me.position.x, me.position.y]
	end if
	if locationOnly == null then
		locationOnly = 0
	end if
    frontier = []
    frontier.push(startNode)
	distance = {}
	distance.push(startNode)
	distance[startNode] = 0
	foundLocation = null
    searched = 0
	numOfLoop = 0
	loop = 1
    while frontier and loop // while there's still tiles to search
		if numOfLoop>globals.numOfLoopToWait then
			numOfLoop = 0
			wait(globals.waitTime)
		end if
		numOfLoop = numOfLoop + 1
        searched = searched + 1
        if searched>searchLimit then 
			//print "Could not find " + tileToLookFor + " : " + tileParameter
			return null
		end if
        currentNode = frontier.pull
        // ****** this can be optimize to not check previously checked location
        neighborTiles = neighbors(currentNode) //save coordinate of the neihboring tiles
        for i in range(0,neighborTiles.len-1) //check tile around current node
            if distance.hasIndex(neighborTiles[i]) then // if node already check, continue to next loop
                continue
            end if
			x = neighborTiles[i][0]
			y = neighborTiles[i][1]
            if (farm.tile(x,y)) then // if tile has info

				// this if block is to make sure the path to the tile is reachable
				if (farm.tile(x,y).hasIndex("passable")) then
					if (farm.tile(x,y).passable == 0) then
						//if tile is what we're looking for then do nothing (loop continues as normal)
						if farm.tile(x,y).hasIndex(tileToLookFor) then
							if farm.tile(x,y)[tileToLookFor] == tileParameter then
								// do nothing and continue loop as usual
							else
								continue
							end if
							
						// next two else if statement is for special case for finding water
						else if (tileToLookFor == "waterSource" and farm.tile(x,y)["name"] == "Water") then
							// do nothing and continue loop as usual
						else if (tileToLookFor == "waterSource" and farm.tile(x,y)["name"] == "Well") then
							//  do nothing and continue loop as usual
						// next five else if statement is for special case for debris
						else if ((tileToLookFor == "debris" or tileToLookFor == "debrisAndTrees") and (farm.tile(x,y).hasIndex("stump")==1 and farm.tile(x,y)["stump"] == 1)) then
							//  do nothing and continue loop as usual
						else if (tileToLookFor == "debrisAndTrees" and farm.tile(x,y)["name"] == "Tree") then
							//  do nothing and continue loop as usual
						else if ((tileToLookFor == "debris" or tileToLookFor == "debrisAndTrees") and farm.tile(x,y)["name"] == "Twig") then
							//  do nothing and continue loop as usual
						else if ((tileToLookFor == "debris" or tileToLookFor == "debrisAndTrees") and farm.tile(x,y)["name"] == "Stone") then
							//  do nothing and continue loop as usual
						else if ((tileToLookFor == "debris" or tileToLookFor == "debrisAndTrees") and farm.tile(x,y)["name"] == "Weeds") then
							//  do nothing and continue loop as usual
						else
							continue
						end if
					end if
					// also skip bush since it's shown as passable but it's not
					if (farm.tile(x,y).hasIndex("type")) then
						if farm.tile(x,y)["type"] == "Bush" then
							continue
						end if
					end if
					// some buildings are passable but should not be
					if (farm.tile(x,y).hasIndex("name")) then
						if farm.tile(x,y)["name"] == "Building" then
							continue
						end if
					end if
				end if
			
				//normal usage
                if (farm.tile(x,y).hasIndex(tileToLookFor) and farm.tile(x,y)[tileToLookFor] == tileParameter) then
                        foundLocation = [x,y]
						loop = 0
				// special case for "waterSource"
				else if (tileToLookFor == "waterSource" and farm.tile(x,y).hasIndex("name")) then
						if (farm.tile(x,y)["name"] == "Water") then
							world.chat("Water source found")
							foundLocation = [x,y]
							loop = 0
						else if (farm.tile(x,y)["name"] == "Well") then
							world.chat("Well water found")
							foundLocation = [x,y]
							loop = 0
						end if
				// special case for "debris" and "debrisAndTrees"
				else if (tileToLookFor == "debris" or tileToLookFor == "debrisAndTrees") then
				
					if (farm.tile(x,y).hasIndex("stump") and farm.tile(x,y)["stump"] == 1) then
							foundLocation = [x,y]
							loop = 0
					else if (farm.tile(x,y).hasIndex("name")) then
						if (farm.tile(x,y)["name"] == "Tree" and tileToLookFor == "debrisAndTrees") then
							foundLocation = [x,y]
							loop = 0
						else if (farm.tile(x,y)["name"] == "Twig") then
							foundLocation = [x,y]
							loop = 0
						else if (farm.tile(x,y)["name"] == "Stone") then
							foundLocation = [x,y]
							loop = 0
						else if (farm.tile(x,y)["name"] == "Weeds") then
							foundLocation = [x,y]
							loop = 0
						end if
					end if
				end if
            end if

			if not distance.hasIndex([x,y]) then
                frontier.push([x,y])
				distance[[x,y]] = distance[currentNode] + 1
			end if
        end for
    end while
	// create shortest path to location
	if foundLocation==null then return null
	if locationOnly==1 then return foundLocation
	path = []
	path.insert(0,foundLocation)
	dist = distance[foundLocation] - 1
	currentNode = foundLocation
	while dist > 0
		wait(0.001)
		neighborTiles = neighbors(currentNode)
		for i in range(0,neighborTiles.len-1) //check neighboring tiles for the next tile
			if (distance.hasIndex(neighborTiles[i]) and distance[neighborTiles[i]]==dist) then
				path.push(neighborTiles[i])
				currentNode = neighborTiles[i]
				dist = dist - 1
			end if
		end for
	end while
	return path
end function

//******************************************************
// uses BFS (call to searchForTile function) to find path then make bot go to location
// set stopBeforeLastNode = 0 for normal pathing, set stopBeforeLastNode = 1 to stop before final node.
// stopBeforeLastNode is useful for pathing to water source, trees, bins, ect.

me.bfsTo = function(tileToLookFor, tileParameter, numTilesToSearch, stopBeforeLastNode)
    maxTries = 5
    numOfTries = 0
    startPos = [me.position.x, me.position.y ]
    
    coordinateList = []
    coordinate = []
	coordinateList = searchForTile(tileToLookFor, tileParameter, numTilesToSearch)
	if coordinateList == null then
		notFound = 1
		return notFound
	end if
    while coordinateList
        coordinate = coordinateList.pop
        if stopBeforeLastNode and coordinateList.len==0 then 
            break // stop before the last node if enabled
        end if
        me.goto(coordinate[0],coordinate[1])
        //check to see if blocked by object and recalculate path
        if me.position.x != coordinate[0] or me.position.y != coordinate[1] then
            wait 0.1
            coordinateList = searchForTile(tileToLookFor, tileParameter, numTilesToSearch)
            numOfTries = numOfTries + 1
            if numOfTries >= maxTries then break
        end if
		if key.pressed("end") then break
    end while
    if stopBeforeLastNode then  //make bot turn towards the destination
        if (me.position.x - coordinate[0]>0) then 
            me.turnWest
        else if ((me.position.x - coordinate[0])<0) then 
            me.turnEast
        else if ((me.position.y - coordinate[1])>0) then 
            me.turnNorth
        else if ((me.position.y - coordinate[1])<0) then 
            me.turnSouth
        end if
    end if;
end function

//**********************************************************************************
//**These Functions are used to calculate heuristics for the pathfinding algorithm**
//**********************************************************************************
    // distance to start location
    gCost = function(currentPos, startNode)
        costToStartPos = abs(currentPos[0]-startNode[0])+abs(currentPos[1]-startNode[1])
        return costToStartPos
    end function
    // distance to destination
    hCost = function(currentPos, endNode)
        costToEndPos = abs(currentPos[0]-endNode[0])+abs(currentPos[1]-endNode[1])
        return costToEndPos
    end function
    // use manhatten distance since only 4 directional movements allowed
    fCost = function(currentPos, startNode, endNode)
        return gCost(currentPos, startNode)+hCost(currentPos, endNode)
    end function
//**********************************************************************************
pathfinding = function (startNode, endNode)
    //implementation of A* pathfinding algorithm. Returns path from startNode to endNode
    //reference: https://www.redblobgames.com/pathfinding/a-star/introduction.html
	//check if coordinate is valid
	if(startNode isa list and endNode isa list) then
		 //continue as normal
	else
		world.chat("not a valid coordinate for path")
		return [[me.position.x,me.position.y]]
	end if
	
    if startNode == endNode then return [endNode] //do nothing if already at destination
	if endNode == null then return null
    frontier = []
    frontier.push([startNode,0])
    cameFrom = {}
    costSoFar = {}
    cameFrom[startNode] = null
    costSoFar[startNode] = 0
    maxNode = 5000  //numbers of node to search for before exiting algorithm to prevent freeze up if path too far or no path exists without searching entire map
    numOfNode = 0
	numOfLoop = 0
    while frontier      //while frontier is not empty
		if numOfLoop>globals.numOfLoopToWait then
			numOfLoop = 0
			wait(globals.waitTime)
		end if
		numOfLoop = numOfLoop + 1
        currentNode = frontier.pull[0]
        numOfNode = numOfNode + 1
        if currentNode == endNode or numOfNode>maxNode then //if at the destination, exit loop
            break
        end if
		//If path is unreachable, coordinate goes negative... this is not a good fix but it's a fix.
		if currentNode[0]<0 or currentNode[1]<0 then
			world.chat("Could not find traversable path")
			return [[me.position.x,me.position.y]]
		end if
        
        neighborTiles = neighbors(currentNode) //save coordinate of the neihboring tiles
        for i in range(0,neighborTiles.len-1) //check tile around current node
            // check if the surrounding tiles are passable, if not, skip loop
            if (farm.tile(neighborTiles[i][0],neighborTiles[i][1]) != null) then
				// for some reason some "Buildings" and "Bush" are shown as passable even though they're not. This statement works around that issue.
                if (farm.tile(neighborTiles[i][0],neighborTiles[i][1]).type=="Building") then 
					if (farm.tile(neighborTiles[i][0],neighborTiles[i][1]).name != "Well") then continue //corner case for wells
                end if
				if (farm.tile(neighborTiles[i][0],neighborTiles[i][1]).type=="Bush") then
					continue
				end if
				if (farm.tile(neighborTiles[i][0],neighborTiles[i][1]).passable==0 and [neighborTiles[i][0],neighborTiles[i][1]] != endNode ) then
					continue
				end if
				
            end if
            
            nextCellNode = [neighborTiles[i][0],neighborTiles[i][1]] // next node to check
            newCost = costSoFar[currentNode] + fCost(nextCellNode,startNode,endNode)
            //if next node is new or if the cost is less than an exisintg "next node", update cost
            if not costSoFar.hasIndex(nextCellNode) or newCost < costSoFar[nextCellNode] then
                costSoFar[nextCellNode] = newCost
                i = 0
                while i<frontier.len  // check cost of all frontier node, update if necessary
                    if frontier[i][1] > newCost then break
                    i = i + 1
                end while
                frontier.insert i, [nextCellNode, newCost]
                cameFrom[nextCellNode] = currentNode
            end if;
        end for
		if frontier.len == 0 then
			world.chat("Could not find traversable path")
		end if
    end while
        
    result = [] // construct a list of node that will act as the path
    if cameFrom.hasIndex(currentNode) then
        while currentNode != startNode
            result.push(currentNode)
            currentNode = cameFrom[currentNode]
        end while
    end if
    return result
end function
//**********************************************
// uses A* (call to pathfinding function) to find path then make bot go to location
// set stopBeforeLastNode = 0 for normal pathing, set stopBeforeLastNode = 1 to stop before final node.
// stopBeforeLastNode is useful for pathing to water source, trees, bins, ect.
me.pathTo = function(endPos,stopBeforeLastNode)
    maxTries = 5
    numOfTries = 0
    startPos = [me.position.x, me.position.y ]
    
    coordinateList = []
    coordinate = []
    coordinateList = pathfinding(startPos, endPos)
    while coordinateList
        coordinate = coordinateList.pop
        if stopBeforeLastNode and coordinateList.len==0 then 
            break // stop before the last node if enabled
        end if
        me.goto(coordinate[0],coordinate[1])
        //check to see if blocked by object and recalculate path
        if me.position.x != coordinate[0] or me.position.y != coordinate[1] then
            wait 0.1
            startPos = [me.position.x, me.position.y]
            coordinateList = pathfinding(startPos, endPos)
            numOfTries = numOfTries + 1
            if numOfTries >= maxTries then break
        end if
		if key.pressed("end") then break
    end while
    if stopBeforeLastNode then  //make bot turn towards the destination
        if (me.position.x - coordinate[0]>0) then 
            me.turnWest
        else if ((me.position.x - coordinate[0])<0) then 
            me.turnEast
        else if ((me.position.y - coordinate[1])>0) then 
            me.turnNorth
        else if ((me.position.y - coordinate[1])<0) then 
            me.turnSouth
        end if
    end if;
    
end function

//**********************************************
me.fetchWater = function
	world.chat( "searching for water" )
	notFound = me.bfsTo("waterSource",1,3000,1)

	if notFound then
		world.chat("No water source found nearby")
	else
		me.water
	end if
end function
//**********************************************
// search bot inventory and return the inventory index.
searchInventory = function (type, typeParameter)
	for i in range(0,me.inventory.len-1)
		if me.inventory[i].hasIndex(type) then
			if me.inventory[i][type]==typeParameter then
				return i
			end if
		end if
	end for
end function
//**********************************************
// search for any dry spot and water it regardless if there's crop or not
waterField = function
    startPos = [me.position.x, me.position.y]
    wateringCanIndex = searchInventory("type","WateringCan")
    state = "searchDry"
	searchCorner = 0
	direction = me.facing
	world.chat("Watering field")
    loop = 1
    while (loop)
		wait(0.01)
        //if there is no water in the watering can
        if me.inventory[wateringCanIndex].waterLeft <= 3 then
            state = "fetchWater"
        end if
    
        if state == "searchDry" then
            notFound = me.bfsTo("dry",1,1000,1)
            if notFound then 
                state = "cleanUp"
            else
				direction = me.facing
                state = "watering"
            end if
        end if
	
        if state == "watering" then
			neighborTiles = neighbors([me.position.x,me.position.y]) //check if neigboring tiles are dry
			for i in range(0,neighborTiles.len-1)
				if farm.tile(neighborTiles[i][0],neighborTiles[i][1]) then
					if farm.tile(neighborTiles[i][0],neighborTiles[i][1]).hasIndex("dry") then
						if farm.tile(neighborTiles[i][0],neighborTiles[i][1])["dry"] == 1 then
							// if they're dry, water them
							me.pathTo([neighborTiles[i][0],neighborTiles[i][1]],1)
							me.water
						end if
					end if
				end if
			end for
			//keeps the robot facing the direction that it was searching for. 
			if direction == 0 then // facing north
				me.turnNorth
			else if direction == 1 then // facing east
				me.turnEast
			else if direction == 2 then // facing south
				me.turnSouth
			else // facing west
				me.turnWest
			end if
			if me.twohead then // ensure two tile ahead is not null
				if me.twohead.hasIndex("dry") then
					if me.twohead["dry"] == 1 then
						me.forward
						searchCorner = 1
					else
						state = "intermediate"
						// world.chat("searching 0")
					end if
				else
					state = "intermediate"
				// world.chat("searching 1")
				end if
			else
				state = "intermediate"
			// world.chat("searching 2")
			end if
		end if
		
		if state == "intermediate" then
			if searchCorner then
				state = "corners"
				searchCorner = 0
			else
				state = "searchDry"
			end if
		end if
		
		// search the diagonals around the robot for dry spots
		if state == "corners" then
			currentPosition = [me.position.x,me.position.y]
			cornerPaths = []
			if farm.tile(currentPosition[0]+1,currentPosition[1]-1) then
				if farm.tile(currentPosition[0]+1,currentPosition[1]-1).hasIndex("dry") then
					if farm.tile(currentPosition[0]+1,currentPosition[1]-1)["dry"]==1 then
						cornerPaths.push([currentPosition[0]+1,currentPosition[1]-1])
					end if
				end if
			end if
			if farm.tile(currentPosition[0]+1,currentPosition[1]+1) then
				if farm.tile(currentPosition[0]+1,currentPosition[1]+1).hasIndex("dry") then
					if farm.tile(currentPosition[0]+1,currentPosition[1]+1)["dry"]==1 then
						cornerPaths.push([currentPosition[0]+1,currentPosition[1]+1])
					end if
				end if
			end if
			if farm.tile(currentPosition[0]-1,currentPosition[1]-1) then
				if farm.tile(currentPosition[0]-1,currentPosition[1]-1).hasIndex("dry") then
					if farm.tile(currentPosition[0]-1,currentPosition[1]-1)["dry"]==1 then
						cornerPaths.push([currentPosition[0]-1,currentPosition[1]-1])
					end if
				end if
			end if
			if farm.tile(currentPosition[0]-1,currentPosition[1]+1) then
				if farm.tile(currentPosition[0]-1,currentPosition[1]+1).hasIndex("dry") then
					if farm.tile(currentPosition[0]-1,currentPosition[1]+1)["dry"]==1 then
						cornerPaths.push([currentPosition[0]-1,currentPosition[1]+1])
					end if
				end if
			end if
			if cornerPaths.len > 0 then
				me.forward
				while cornerPaths.len > 0
					me.pathTo(cornerPaths.pop,1)
					me.water
				end while
				me.pathTo(currentPosition)
			end if
			state = "searchDry"
		end if
        
        if state == "fetchWater" then
            // save position so we can come back to it
            savePosition = [me.position.x, me.position.y]
            saveDirection = me.facing
            me.fetchWater                   // to get water
            me.pathTo(savePosition,0)       // go back to saved position
            if saveDirection == 0 then
                me.turnNorth
            else if saveDirection == 1 then
                me.turnEast
            else if saveDirection == 2 then
                me.turnSouth
            else
                me.turnWest
            end if
            state = "watering"
        end if
    
        if state == "cleanUp" then                    // once done, refill water, go back to starting position
            loop = 0
            if me.inventory[wateringCanIndex].waterLeft < me.inventory[wateringCanIndex].waterMax then
                me.fetchWater
            end if
            me.pathTo(startPos,0)
            me.turnSouth
			world.chat("Field watered")
        end if
		
		if key.pressed("end") then
			world.chat("Stopped watering field")
			break
		end if
    end while
end function
//**********************************************
// clears Twig, stones, weeds, stump, and tree if clearTree = 1.
// may clear player planted trees so use with caution. Have not tested.
clearField = function
    startPos = [me.position.x, me.position.y]
	world.chat("Clearing Land")
	loop = 1
	state = "clearing"
	location = null
	area = [4,10,20,40,100,500,1000,3000,5000]
	i = 0
	while loop
		wait(0.01)
		// key press to determine what to clear
		if key.pressed("up") then
			if (globals.clearMode != "debris") then world.chat("Clearing debris only")
			globals.clearMode = "debris"
		end if
		if key.pressed("down") then
			if (globals.clearMode != "debrisAndTrees") then world.chat("And trees")
			globals.clearMode = "debrisAndTrees"
		end if
		if key.pressed("end") then
			globals.clearTree = 0
			world.chat("Stopped clearing field")
			break
		end if
		
		if state == "clearing" then
            notFound = me.bfsTo(globals.clearMode,1,5000,1)
			if notFound then
				state = "cleanUp"
            else
                me.clearAhead
			end if
		end if
		
        if state == "cleanUp" then  
            loop = 0
            me.pathTo(startPos,0)
            me.turnSouth
			world.chat("Field cleared")
        end if
	end while
end function
//**********************************************
// Remote control the robot with directional keys
// Choose different mode to walk-only, water land, DESTROY!!!
remoteControl = function(onOff)
	action = function(mode)
		if mode == "demolish" then
			if me.ahead then 
				me.clearAhead
			else
				me.forward
			end if
		else if mode == "water" then
			if me.ahead == null then
				me.forward
			else if me.ahead.hasIndex("dry") then
				if me.ahead["dry"]==1 then 
					me.water
				else
					me.forward
				end if
			end if
		else if mode == "movementOnly" then
			me.forward
		end if
	end function

	wateringCanIndex = searchInventory("type","WateringCan")
	mode = "movementOnly" //movementOnly, demolish, water
	if onOff then
		world.chat("Remote Control Mode ON")
		world.chat("Mode Activated: Move-Only")
		while(1)
			wait (0.02)
		
			if me.inventory[wateringCanIndex].waterLeft <= 3 then
                me.fetchWater
            end if
		
			if key.pressed("[1]") then
				if mode != "movementOnly" then world.chat("Activated: Move-Only Mode")
				mode = "movementOnly"
			end if
			if key.pressed("[2]") then
				if mode != "water" then world.chat("Activated: Watering Mode")
				mode = "water"
			end if
			if key.pressed("[3]") then
				if mode != "demolish" then world.chat("Activated: Demolish Mode")
				mode = "demolish"
			end if
			
			if key.pressed("left") then
				me.turnWest
				action(mode)
			end if
			if key.pressed("right") then
				me.turnEast
				action(mode)
			end if
			if key.pressed("up") then
				me.turnNorth
				action(mode)
			end if
			if key.pressed("down") then
				me.turnSouth
				action(mode)

			end if
			if key.pressed("end") or key.pressed("home") or key.pressed("f1") or key.pressed("f2") or key.pressed("f5") or key.pressed("f6") then
				world.chat("Remote Control Mode OFF")
				break
			end if
		end while
	end if

end function

//**********************************************
// Till land in a rectangular shape using corner 1 and corner 2
tillField = function(firstCorner, secondCorner,untill)
	//check if coordinate is valid
	if(firstCorner isa list and secondCorner isa list) then
		if(firstCorner.len==2  and secondCorner.len==2) then
		 //continue as normal
		else
			 world.chat("not a valid coordinate")
			return
		end if
	else
		world.chat("not a valid coordinate")
		return
	end if
	deltaX = secondCorner[0]-firstCorner[0]
	deltaY = secondCorner[1]-firstCorner[1]
	fieldMap = {}
	startY = 0
	endY = deltaY
	tempY = 0
	for i in range(0,deltaX)
		for j in range(startY, endY)
			x = firstCorner[0] + i
			y = firstCorner[1] + j
			wait(0.1)
			if key.pressed("end") then 
				world.chat("Tillage cancelled.")
				return
			end if
			if farm.tile(x,y) != null then // check to see if bot is standing on the tile
				if farm.tile(x,y).hasIndex("type") then
					if farm.tile(x,y)["type"] == "BotObject" then
						me.moveToNextAvailableTile
					end if
				end if
			end if
			if untill then // if untill is selected, then untill land
				if farm.tile(x,y) != null then
					if farm.tile(x,y).hasIndex("type") then
						if farm.tile(x,y)["type"]=="HoeDirt" then
							me.pathTo([x,y],1)
							me.clearAhead
						end if
					end if
				end if
			else // else till the land
				if farm.tile(x,y) == null then
					me.pathTo([x,y],1)
					me.till
				end if
			end if
		end for
		tempY = startY
		startY = endY
		endY = tempY
	end for
end function

tillMode = function
	world.chat("Tillage-mode Activated")
	confirm = 0
	firstCorner = null
	secondCorner = null
	locationOnly = 1
	areaOfSearch = 5000
	while(1)
		wait(0.1)
		if key.pressed("left") then 
			firstCorner = searchForTile("name",me.owner,areaOfSearch,locationOnly)
			world.chat("Till start location selected at" + firstCorner)
			wait(1)
		end if
		if key.pressed("right") then 
			secondCorner = searchForTile("name",me.owner,areaOfSearch,locationOnly)
			world.chat("Till end location selected at" + secondCorner)
			wait(1)
		end if
		if key.pressed("up") then 
			if confirm == 0 then
				world.chat("Press UP again to confirm untilling from " + firstCorner + " to " + secondCorner + ".")
				confirm = 1
				wait(1)
			else 
				confirm = 0
				world.chat("Untilling land from" + firstCorner + " to " + secondCorner + ".")
				tillField(firstCorner,secondCorner,1)
				wait(1)	
			end if
		end if
		if key.pressed("down") then 
			world.chat("Tilling land from" + firstCorner + " to " + secondCorner + ".")
			tillField(firstCorner,secondCorner,0)
			wait(1)	
		end if
		if key.pressed("end") then 
			world.chat("Exiting Tillage-Mode.")
			break
		end if
	end while
end function

me.rename = function
	h = farm["height"]
	w = farm["width"]
	myPosition = [me.position.x,me.position.y]
	botCount = 0
	for i in range (0,w)
		wait(0.001)
		for j in range(0,h)
			if myPosition == [i,j] then
				me.name = "Bot"+botCount
				return
			end if
			if farm.tile(i,j)!=null and farm.tile(i,j).indexOf("BotObject")!=null then
				botCount = botCount + 1
			end if
		end for
	end for
end function
//**********************************************
//**********************************************
// Auto start this every morning or after robot restarts
me.helpInstruction = function
	world.chat("HOLD KEY FOR UP TO 1/2 SEC TO ACTIVATE")
	world.chat("F1: Water Field")
	world.chat("F2: Go to owner")
	wait(10)
	world.chat("F3: Remote Control,  While in Remote-Control Mode:") 
	world.chat("  D-arrow: movement") 
	world.chat("  numPad-1: Move-only-Mode")
	world.chat("  numPad-2: Watering-mode")
	world.chat("  numPad-3: Demolish-mode")
	wait(10)
	world.chat("F5: Tillage mode:")
	world.chat("  LEFT key: set corner 1 at player location")
	world.chat("  RIGHT key: set corner 2 at player location")
	world.chat("  DOWN key: till from corner 1 to corner 2")
	world.chat("  UP key: untill from corner 1 to corner 2")
	wait(10)
	world.chat("F6: Clear land, while robot in this mode:")
	world.chat("  UP key: clear debris only (default)")
	world.chat("  DOWN key: include tree")
	wait(10)
	world.chat("END key: Terminate most of these programs")
	world.chat("HOME key: Go to location where bot was placed down")
	world.chat("Hold H to repeat these instructions")
end function

if me.isBot then
	me.rename
	homePosition = [me.position.x,me.position.y]
	//waterField
	world.chat("Hold H for instruction")
	while(1)
		wait(0.3)
		if key.pressed("home") then
			world.chat("Returning home at " + homePosition)
			me.pathTo(homePosition,0)
		end if
		if key.pressed("f1") then waterField
		if key.pressed("f2") then
			world.chat("Going to " + me.owner)
			me.bfsTo("name",me.owner,5000,1)
			me.turnSouth
		end if
		if key.pressed("f3") then remoteControl(1)
		if key.pressed("f5") then tillMode 
		if key.pressed("f6") then clearField
		if key.pressed("h") then me.helpInstruction
	end while
end if
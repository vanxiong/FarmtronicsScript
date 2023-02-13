// saved 2/10/2023
// globals
waterLocation = []
wellLocation = []
seletectedWaterLocation = []
waitTime = 0.0001 // in seconds
numOfLoopToWait = 10
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
		wait(0.001)
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
// uses Breadth First Search Algorithm to search for tiles. Resource intensive if area is large
// reference: https://www.redblobgames.com/pathfinding/a-star/introduction.html
// example usage, searchFor("dry",0, 100, startingLocation), searchFor("name","Parsnip", 1000), etc.
// if startPos is not entered, starting location will be at BOT location
// numTilesToSearch specify how many tiles to search. If not used, then defauts to 500 tiles
searchForTile = function(tileToLookFor, tileParameter, numTilesToSearch, startPos)
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
    frontier = []
    frontier.push(startNode)
    checkedNode = {}
    checkedNode.push(startNode)
    searched = 0
	numOfLoop = 0
    while frontier // while there's still tiles to search
		if numOfLoop>globals.numOfLoopToWait then
			numOfLoop = 0
			wait(globals.waitTime)
		end if
		numOfLoop = numOfLoop + 1
        if searched>searchLimit then 
			//print "Could not find " + tileToLookFor + " : " + tileParameter
			return null
		end if
        searched = searched + 1
        currentNode = frontier.pull
        // ****** this can be optimize to not check previously checked location
        neighborTiles = neighbors(currentNode) //save coordinate of the neihboring tiles
        for i in range(0,neighborTiles.len-1) //check tile around current node
            if (farm.tile(neighborTiles[i][0],neighborTiles[i][1])) then // if tile has info
			
				// this if block is to make sure the path to the tile is reachable
				if (farm.tile(neighborTiles[i][0],neighborTiles[i][1]).hasIndex("passable")) then
					if (farm.tile(neighborTiles[i][0],neighborTiles[i][1]).passable == 0) then
						//if tile is what we're looking for then do nothing (loop continues as normal)
						if farm.tile(neighborTiles[i][0],neighborTiles[i][1]).hasIndex(tileToLookFor) then
							if farm.tile(neighborTiles[i][0],neighborTiles[i][1])[tileToLookFor] == tileParameter then
								// do nothing and continue loop as usual
							else
								continue
							end if
						else
							continue
						end if
					end if
					// also skip bush since it's shown as passable but it's not
					if (farm.tile(neighborTiles[i][0],neighborTiles[i][1]).hasIndex("type")) then
						if farm.tile(neighborTiles[i][0],neighborTiles[i][1])["type"] == "Bush" then
							continue
						end if
					end if
					// some buildings are passable but should not be
					if (farm.tile(neighborTiles[i][0],neighborTiles[i][1]).hasIndex("type")) then
						if farm.tile(neighborTiles[i][0],neighborTiles[i][1])["type"] == "Building" then
							if (farm.tile(neighborTiles[i][0],neighborTiles[i][1]).name != tileParameter) then continue
						end if
					end if
				end if
			
                if (farm.tile(neighborTiles[i][0],neighborTiles[i][1]).hasIndex(tileToLookFor)) then
                    if (farm.tile(neighborTiles[i][0],neighborTiles[i][1])[tileToLookFor] == tileParameter) then
                        return [neighborTiles[i][0],neighborTiles[i][1]]
                    end if
                end if
            end if

            if not checkedNode.hasIndex(neighborTiles[i]) then // 
                checkedNode.push(neighborTiles[i])
                frontier.push(neighborTiles[i])
            end if
        
        end for
    end while
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
    //implementation of A* pathfinding algorithm. 
    //reference: https://www.redblobgames.com/pathfinding/a-star/introduction.html
	
	//check if coordinate is valid
	if(startNode isa list and endNode isa list) then
		 //continue as normal
	else
		print("not a valid coordinate")
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
	globals.waterLocation = searchForTile("name","Water",2000)
	globals.wellLocation = searchForTile("name","Well",2000)

	if globals.waterLocation!=null or globals.wellLocation!=null then
		if globals.waterLocation!=null then 
			waterPath = pathfinding([me.position.x, me.position.y],globals.waterLocation)
		end if
		if globals.wellLocation!=null then 
			wellPath = pathfinding([me.position.x, me.position.y],globals.wellLocation)
		end if
		// choose the closest available water source
		if globals.waterLocation!=null and globals.wellLocation!=null then
			if waterPath.len<wellPath.len then
				world.chat( "Generic Water Found" )
				globals.seletectedWaterLocation =  globals.waterLocation
			else
				world.chat( "Well Water Found")
				globals.seletectedWaterLocation = globals.wellLocation
			end if
		else if globals.waterLocation!=null then
			world.chat( "Generic Water Found" )
			globals.seletectedWaterLocation =  globals.waterLocation
		else if globals.wellLocation!=null then
			world.chat( "Well Water Found" )
			globals.seletectedWaterLocation = globals.wellLocation
		end if
		
		me.pathTo(globals.seletectedWaterLocation,1)
		me.water
	else
		world.chat("No water source found nearby")
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
    state = "watering"
	world.chat("Watering field")
    loop = 1
    while (loop)
        //if there is no water in the watering can
        if me.inventory[wateringCanIndex].waterLeft == 0 then
            state = "fetchWater"
        end if
    
        if state == "watering" then
            location = searchForTile("dry",1,1000) // change this to fit your field, 200 tiles is approximately 10-11 tile radius
            if location == null then 
                state = "cleanUp"
            else
                me.pathTo(location,1)
                me.water
            end if
            
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
    
    end while
end function
//**********************************************
// clears Twig, stones, weeds, stump, and tree if clearTree = 1.
// may clear player planted trees so use with caution. Have not tested.
clearField = function(clearTree)
    startPos = [me.position.x, me.position.y]
	world.chat("Clearing Land")
	loop = 1
	state = "clearing" //name:Twig, stump:1, name:Weeds, name:Stone, name:Tree
	location = null
	area = [4,10,20,40,100,500,1000,3000,5000]
	i = 0
	numOfStages = 6
	while loop
		wait(0.01)
		if state == "clearing" then
			if location == null then
				location = searchForTile("name","Twig",area[i])
			end if
            if location == null then 
                location = searchForTile("name","Stone",area[i])
            end if
			if location == null then 
                location = searchForTile("name","Weeds",area[i])
            end if
			if location == null then 
                location = searchForTile("stump",1,area[i])
            end if
			if location == null then 
				if clearTree then location = searchForTile("name","Tree",area[i])
            end if
			if location != null then
				i = 0
                me.pathTo(location,1)
                me.clearAhead
				location = null
            else
				i = i+1
			end if
			if i>numOfStages then
				state = "cleanUp"
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


asdf = function

		if state == "Stump" then
            location = searchForTile("stump",1,3000)
            if location == null then 
                state = "Stone"
            else
                me.pathTo(location,1)
                me.clearAhead
            end if
		end if
			
		if state == "Stone" then
            location = searchForTile("name","Stone",3000)
            if location == null then 
                state = "cleanUp"
            else
                me.pathTo(location,1)
                me.clearAhead
            end if
		end if
			
        if state == "cleanUp" then  
            loop = 0
            me.pathTo(startPos,0)
            me.turnSouth
			world.chat("Field cleared")
        end if
end function
//**********************************************
//**********************************************
// Auto start this every morning or after robot restarts
if me.isBot then
    //waterField
end if

# FarmtronicsScript
Some useful commands:
me.goto(x,y) commands bot to go to coordinate x,y without pathfinding

pathfinding(startNode, endNode)  returns a path as a list of coordinate

me.pathTo([x,y],stopBeforeLastNode) commands the bot to go to coordinate x,y with A* pathfinding
	stopBeforeLastNode: stop one node before the last node. Use for pathing to unpassable object such as wells, trees, buildings

searchForTile(tileToLookFor, tileParameter, numTilesToSearch, startPos)  returns the location of the closest searched tile if found
	tileToLookFor: tile index
	tileParameter: tile parameter of tileToLookFor
	numTilesToSearch: how many tiles to search for before returning with not found. Default to 500 if not passed in
	startPos: starting location of search. Defaults to bot location if not passed in

me.fetchWater command the bot to look for the closest water source

waterField command the bot to water dry tilled land

clearField(includeTree) commands the bot to clear the land of rocks, weeds, stumps, twigs, and optionally trees if includeTree = 1




Will update this later

# FarmtronicsScript
This is a script for a MOD called Farmtronics for the game STARDEW VALLEY
********************************************************************************************
When activating Bot, it will display in chat the following:
* "HOLD KEY FOR UP TO 1 SEC TO ACTIVATE"
* "***F1***: Water Field"
* "***F2***: Go to owner"
* "***F3***: Remote Control,  While in Remote-Control Mode:"
	* "  ***D-arrow***: movement"
	* "  ***numPad-1***: Move-only-Mode"
	* "  ***numPad-2***: Watering-mode"  
	* "  ***numPad-3***: Demolish-mode"
* "***F5***: Clear land excluding trees"
* "***F6***: Clear land, while robot in this mode:"
	* "  ***UP*** key: clear debris only (default)")
	* "  ***LEFT*** key: include tree")
	* "  ***RIGHT*** key: include tilled land")
* "***END*** key: Terminate most of these programs"
* "***HOME*** key: Go to location where bot was placed down"
* "Hold ***H*** to repeat these instructions"
	
The script polls the key.pressed function every 1 second so users may have to to hold these keys for up to 1 second before it registers.


********************************************************************************************
### Some other useful commands:
* ***me.goto(x,y)*** : commands bot to go to coordinate x,y without pathfinding
* ***pathfinding([startX,startY], [endX,endY])*** : returns a path as a list of coordinate
* ***me.pathTo([x,y],stopBeforeLastNode)*** : commands the bot to go to coordinate x,y with A* pathfinding
	* stopBeforeLastNode : stop one node before the last node. Use for pathing to unpassable object such as wells, trees, buildings
* ***searchForTile(tileToLookFor, tileParameter, numTilesToSearch, startPos)*** : returns the location of the closest searched tile if found
	* ***tileToLookFor***: tile index
	* ***tileParameter***: tile parameter of tileToLookFor
	* ***numTilesToSearch***: how many tiles to search for before returning with not found. Default to 500 if not passed in
	* ***startPos***: starting location of search as a list. Defaults to bot location if not passed in
* ***me.fetchWater*** : command the bot to look for the closest water source
* ***waterField*** : command the bot to water dry tilled land
* ***clearField(includeTree)*** : commands the bot to clear the land of rocks, weeds, stumps, twigs, and optionally trees if includeTree = 1


********************************************************************************************

Will update this later

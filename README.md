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
* "***F5***: Tillage mode:"
	* "  ***LEFT*** key: set corner 1 at player location"
	* "  ***RIGHT*** key: set corner 2 at player location"
	* "  ***DOWN*** key: till from corner 1 to corner 2"
	* "  ***UP*** key: untill from corner 1 to corner 2"
* "***F6***: Clear land, while robot in this mode:"
	* "  ***UP*** key: clear debris only (default)"
	* "  ***DOWN*** key: include tree"
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
* ***searchForTile(tileToLookFor, tileParameter, numTilesToSearch, locationOnly, startPos)*** : returns the path of the closest searched tile if found
	* ***tileToLookFor***: tile index. Special index: "waterSource" for all water Source, "debris" and "debrisAndTrees" for stump, weed, rock, twig, and optionally trees.
	* ***tileParameter***: tile parameter of tileToLookFor
	* ***numTilesToSearch***: how many tiles to search for before returning with not found. Default to 500 if not passed in.
	* ***locationOnly***: When == 1, returns the location instead of the full path.
	* ***startPos***: starting location of search as a list. Defaults to bot location if not passed in.
* ***me.fetchWater*** : command the bot to look for the closest water source
* ***waterField*** : command the bot to water dry tilled land
* ***clearField*** : commands the bot to clear the land of rocks, weeds, stumps, twigs, and optionally trees (directional key to select what to destroy)


********************************************************************************************

Will update this later

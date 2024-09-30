extends TileMap


var astar_grid = AStarGrid2D.new()
var PLAYER_CHAR = CharacterBody2D.new()
const MAIN_LAYER = 0
const MAIN_SOURCE = 0
const IS_SOLID = "is_solid"

# variable for grey-colored box to draw out path taken
const PATH_TAKEN_ATLAS_COORDS = Vector2i(2, 0)


## Called when the node enters the scene tree for the first time.
## Runs everything
func _ready():
	
	setup_grid()
	show_path()

## Function for setting up the map grid coordinates
func setup_grid():
	
	# Rect2i -> Rectangle starting position in gamecamera (coordinate)
	# & width/height of the rectangle, last two numbers (8x8) boxes
	astar_grid.region = Rect2i(-3, -3, 8, 8)
	
	# cell_size for tileMaps (coordinates), if you 
	# wish to draw out something on an exact place on them
	astar_grid.cell_size = Vector2i(64, 64)
	
	# Rule system for movement
	# No diagonal movement
	astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	
	# Needed for updating the grid
	astar_grid.update()
	
	# Go through all cells that are used on the MAIN_LAYER (0) of TileMap
	# Check if they are SOLID, and print all coordinates
	for cell in get_used_cells(MAIN_LAYER):
		#prints(cell,is_spot_solid(cell))
		astar_grid.set_point_solid(cell, is_spot_solid(cell),)

func show_path():
	
	# Coordinates of what cells path is taking
	# From 0,0 -> 4,1
	var path_taken = astar_grid.get_id_path(Vector2i(0,0), Vector2i(4, 1))
	
	
	# For every cell that the path takes,
	# Each tile gets colored, that of "var PATH_TAKEN_ATLAS_COORDS (brown)"
	# And a timer is added, to show the flow of movement
	for cell in path_taken:
		set_cell(MAIN_LAYER, cell, MAIN_SOURCE, PATH_TAKEN_ATLAS_COORDS)
		await get_tree().create_timer(.5).timeout
	
	## Function to check if the movement on MAIN_LAYER
	## is SOLID, which is adjusted on TileSet options (custom data layers)
func is_spot_solid(spot_to_check:Vector2i) -> bool:
	return get_cell_tile_data(MAIN_LAYER, spot_to_check).get_custom_data(IS_SOLID)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


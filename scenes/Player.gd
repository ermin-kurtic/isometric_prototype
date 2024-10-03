extends Node2D

@onready var tile_map = $"../TileMap"

var astar_grid = AStarGrid2D.new()
const MAIN_LAYER = 0
const MAIN_SOURCE = 0
const IS_SOLID = "is_solid"

# variable for grey-colored box to draw out path taken
const PATH_TAKEN_ATLAS_COORDS = Vector2i(2, 0)
# Variable for the size of the map rectangle
# const MAP_RECT = Rect2i(-3, -3, 8, 8)

var current_id_path: Array[Vector2i]
var target_position: Vector2
var is_moving: bool
var current_point_path: PackedVector2Array




## Called when the node enters the scene tree for the first time.
## Runs everything
func _ready():
	
	setup_grid()
	show_path()
	
## Function for setting up the map grid coordinates
func setup_grid():
	
	# Rect2i -> Rectangle starting position in gamecamera (coordinate)
	# & width/height of the rectangle, last two numbers (8x8) boxes
	astar_grid.region = tile_map.get_used_rect()
	
	# cell_size for tileMaps (coordinates), if you 
	# wish to draw out something on an exact place on them
	# astar_grid.cell_size = Vector2i(64, 64)
	
	# Rule system for movement
	# No diagonal movement
	astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	
	# Needed for updating the grid
	astar_grid.update()
	
	# Go through all cells that are used on the MAIN_LAYER (0) of TileMap
	# Check if they are SOLID, and print all coordinates
	for cell in tile_map.get_used_cells(MAIN_LAYER):
		#prints(cell,is_spot_solid(cell))
		astar_grid.set_point_solid(cell, is_spot_solid(cell),)

func show_path():
	
	# Coordinates of what cells path is taking
	# From 0,0 -> 4,1
	var path_taken = astar_grid.get_id_path(Vector2i(0,0), Vector2i(4, 1))
	
	## Function to check if the movement on MAIN_LAYER
	## is SOLID, which is adjusted on TileSet options (custom data layers)
func is_spot_solid(spot_to_check:Vector2i) -> bool:
	return tile_map.get_cell_tile_data(MAIN_LAYER, spot_to_check).get_custom_data(IS_SOLID)
	
	
# Global function that does not need to be called upon in _ready
func _input(event):
	
	if event.is_action_pressed("move_to") == false:
		return
		
	var id_path
	
	# Calculation for the Arrays from start to end
	# Slice/Remove first Array (starting point)
	if is_moving:
		id_path = astar_grid.get_id_path(
			tile_map.local_to_map(target_position),
			tile_map.local_to_map(get_global_mouse_position()),
	)
	else: 
		id_path = astar_grid.get_id_path(
			tile_map.local_to_map(global_position),
			tile_map.local_to_map(get_global_mouse_position())
		).slice(1)
	
	if id_path.is_empty() == false:
		current_id_path = id_path
		
		current_point_path = astar_grid.get_point_path(
			tile_map.local_to_map(target_position),
			tile_map.local_to_map(get_global_mouse_position())
		)
		
	# For every cell that the path takes,
	# Each tile gets colored, that of "var PATH_TAKEN_ATLAS_COORDS (brown)"
	# And a timer is added, to show the flow of movement
		for cell in id_path:
			tile_map.set_cell(MAIN_LAYER, cell, MAIN_SOURCE, PATH_TAKEN_ATLAS_COORDS)
		#await get_tree().create_timer(.1).timeout
		
		
# Global function that does not need to be called upon in _ready
func _physics_process(delta):
	
	if current_id_path.is_empty():
		return
	
	if is_moving == false:
		# front(). takes the first item in Array
		target_position = tile_map.map_to_local(current_id_path.front())
		is_moving = true
	
	global_position = global_position.move_toward(target_position, 2)
	
	# Runs only when player reaches target poisition
	if global_position == target_position:
		current_id_path.pop_front()
		
		if current_id_path.is_empty() == false:
			target_position = tile_map.map_to_local(current_id_path.front())
		else:
			is_moving = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


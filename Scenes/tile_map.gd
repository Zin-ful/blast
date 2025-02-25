extends TileMap

var moist
var moisture = FastNoiseLite.new()
var temperature = FastNoiseLite.new()
var altitude = FastNoiseLite.new()
var width = 100
var height = 50
@onready var world_check_timer = $Timer
@onready var player = get_node("/root/game/Player")

var loaded_chunks = []
#total tiles / num = length
var player_pos
var space_main_source_id = 0 
var space_main_atlas = Vector2i(47,0)

var space_main_star_arr= []
var space_main_star_cls_arr = [] 

var space_main_star_terr = 1
var space_main_star_cls_terr = 2

var space_main_layer = 0
var space_main_star_layer = 1
var space_main_star_cls_layer = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	moisture.seed = randi() # Replace with function body.
	temperature.seed = randi()
	altitude.seed = randi()
	player = get_tree().get_root().find_child("Player", true, false)  # Recursively find Player
	if player == null:
		print("Error: Player not found in scene tree!")
	else:
		print("Player found:", player)
		world_check_timer.timeout.connect(_on_timer_timeout)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_timer_timeout() -> void:
	var player_tile_pos = local_to_map(player.position)
	generate_chunk(player_tile_pos)
	unload_distant_chunks(player_tile_pos)

func generate_chunk(pos):
	for x in range(width):
		for y in range(height):
			# Generate noise values for moisture, temperature, and altitude
			moist = moisture.get_noise_2d(pos.x - width/2 + x, pos.y - height/2 + y) * 10 # Values between -10 and 10
			var temp = temperature.get_noise_2d(pos.x - width/2 + x, pos.y - height/2 + y) * 10
			var alt = altitude.get_noise_2d(pos.x - width/2 + x, pos.y - height/2 + y) * 10

			set_cell(0, Vector2i(pos.x - width/2 + x, pos.y - height/2 + y), 0, Vector2(round(3 * (moist + 10) / 20), 0))
			if alt > 7:
				set_cell(0, Vector2i(pos.x - width/2 + x, pos.y - height/2 + y), 0, Vector2(round(3 * (moist + 10) / 20), 1))
			if Vector2i(pos.x, pos.y) not in loaded_chunks:
				loaded_chunks.append(Vector2i(pos.x, pos.y))

			
func unload_distant_chunks(player_pos):
	# Set the distance threshold to at least 2 times the width to limit visual glitches
	# Higher values unload chunks further away
	var unload_distance_threshold = (width * 2) + 1
	for chunk in loaded_chunks:
		var distance_to_player = get_dist(chunk, player_pos)
		if distance_to_player > unload_distance_threshold:
			clear_chunk(chunk)
			loaded_chunks.erase(chunk)
# Function to clear a chunk
func clear_chunk(pos):
	for x in range(width):
		for y in range(height):
			set_cell(0, Vector2i(pos.x - width/2 + x, pos.y - height/2 + y), -1, Vector2(-1, -1), -1)
func get_dist(vec1, vec2):
	var resultant = vec2 - vec1
	return sqrt(resultant.x**2 + resultant.y**2)

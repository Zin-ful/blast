extends Node2D

@export var noise_height_texture : NoiseTexture2D
@onready var player: CharacterBody2D = $Player
@onready var tile_map = $TileMap
@onready var world_check_timer = $Timer

var noise: Noise

var player_pos
var player_pos_cache

var radius : int = 100

var noise_array = []

var space_main_source_id = 0 
var space_main_atlas = Vector2i(47,0)

var space_main_star_arr= []
var space_main_star_cls_arr = [] 

var space_main_star_int = 0
var space_main_star_cls_int = 1

var space_main_layer = 0
var space_main_star_layer = 1
var space_main_star_cls_layer = 2


var space_main_planet_med_atlas = 0 
var space_main_planet_sml_atlas = 0 
var space_main_planet_cls_atlas = 0 

var planet_atlas
func _ready() -> void:
	player_pos = player.position
	noise = noise_height_texture.noise
	gen_world()
	world_check_timer.timeout.connect(_on_timer_timeout)
func _process(delta: float) -> void:
	player_pos = player.position
	
func _on_timer_timeout() -> void:
	noise = noise_height_texture.noise
	if player_pos.x < (player_pos.x / 2) || player_pos.y < (player_pos.y / 2):
		gen_world()


func gen_world():
	var world_coords = tile_map.local_to_map(player_pos)
	var new_star_arr = []  # Temporary array for star tiles
	var new_star_cls_arr = []  # Temporary array for classified star tiles
	
	for x in range(player_pos.x - radius, player_pos.x + radius + 1):
		for y in range(player_pos.y - radius, player_pos.y + radius + 1):
			var tile_pos = Vector2i(x, y)  # Create only once

			# Skip if tile already exists
			if tile_map.get_cell_source_id(space_main_layer, tile_pos) != -1:
				continue  
			
			var get_noise = noise.get_noise_2d(x, y)

			# Store in batch arrays instead of setting one by one
			if get_noise > 0.3:
				new_star_cls_arr.append(tile_pos)
			elif get_noise > 0.0 && get_noise < 0.3:
				new_star_arr.append(tile_pos)
			
			# Set tile
			tile_map.set_cell(space_main_layer, tile_pos, space_main_source_id, space_main_atlas)

	# Batch set terrain to reduce function calls
	tile_map.set_cells_terrain_connect(space_main_star_layer, new_star_arr, space_main_star_int, 0)
	tile_map.set_cells_terrain_connect(space_main_star_cls_layer, new_star_cls_arr, space_main_star_cls_int, 0)

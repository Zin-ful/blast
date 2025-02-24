extends Node2D

@export var noise_height_texture : NoiseTexture2D

@onready var tile_map = $TileMap

var noise: Noise
var offset_x = width / 2  # Adjust for negative index offset
var offset_y = height / 2

var width : int = 500
var height : int = 500

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
	noise = noise_height_texture.noise
	gen_world()
	
func _process(delta: float) -> void:
	pass

func gen_world():
	for x in range(-width/2, width/2):
		for y in range(-height/2, height/2):
			var tile_pos = Vector2i(x + offset_x, y + offset_y)  # Offset to positive values
			var get_noise = noise.get_noise_2d(x, y)
			noise_array.append(get_noise)
			if get_noise > 0.3:
				space_main_star_cls_arr.append(tile_pos)
			elif get_noise > 0.0 && get_noise < 0.3:
				space_main_star_arr.append(tile_pos)
			tile_map.set_cell(space_main_layer, Vector2i(x,y), space_main_source_id, space_main_atlas)
	tile_map.set_cells_terrain_connect(space_main_star_layer, space_main_star_arr, space_main_star_int, 0)
	tile_map.set_cells_terrain_connect(space_main_star_cls_layer, space_main_star_cls_arr, space_main_star_cls_int, 0)
	print(noise_array.max())
	print(noise_array.min())

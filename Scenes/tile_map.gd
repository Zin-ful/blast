extends TileMap

@onready var particles: GPUParticles2D = $"star field back" 
@onready var world_check_timer = $Timer
@onready var player = get_node("/root/game/Player")
@onready var overlay_tilemap1 = get_node("/root/game/Sprites/Enviorments/maphere")
@onready var overlay_tilemap2 = get_node("/root/game/Sprites/Enviorments/maphere")
@onready var overlay_tilemap3 = get_node("/root/game/Sprites/Enviorments/maphere")

#particle generation
const MAX_PARTICLES = 1000
var total_particles = 0

#noise values
var moist
var moisture = FastNoiseLite.new()
var temperature = FastNoiseLite.new()
var altitude = FastNoiseLite.new()
var width = 100
var height = 50


var loaded_chunks = []
var player_pos

#sprite values
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
	spawn_global_particles()
	if total_particles < MAX_PARTICLES:
		total_particles += particles.amount
	else:
		particles.emitting = false
		
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
			#if moist > 5:  # if we overlay another tilemap to generate like stars or planets
				#overlay_tilemap1.set_cell(0, Vector2i(pos.x - width/2 + x, pos.y - height/2 + y), 1, Vector2(2, 0))
			#if alt > 5 and moist > 3:  # Example condition for tree placement
				#var tree = tree_scene.instantiate()
				#tree.position = map_to_local(Vector2i(pos.x - width/2 + x, pos.y - height/2 + y))  # Convert tile position to world coordinates
				#add_child(tree)
			
			
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

func spawn_global_particles():
	if particles:  # Prevent duplicates
		particles = GPUParticles2D.new()
		particles.process_material = ParticleProcessMaterial.new()
		
		# Set particle texture
		#var shader = preload("res://Sprites/Enviorments/test stars 2.png")  
		#particles.process_material.shader = shader
		#particles.texture = preload("res://")
		# Particle Settings
		particles.amount = 10 # Number of particles
		particles.lifetime = 10000  # Effectively infinite lifetime
		particles.one_shot = true  # Keep emitting indefinitely
		particles.emitting = true
		particles.local_coords = false  # Makes the particles global
		particles.explosiveness = 0.0  # Continuous emission
		particles.preprocess = 10  # Preload particles instantly
		particles.speed_scale = 100
		particles.position = player.position
		# Particle Process Material (Controls Movement & Physics)
		var material = particles.process_material
		material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
		material.emission_box_extents = Vector3(1000,1000,0)
		material.gravity = Vector3(0, 0, 0)  # Slight upward lift
		material.initial_velocity_min = 0
		material.initial_velocity_max = 0
		material.direction = Vector3(0, 0, 0)  # Moves mostly in X direction
		material.spread = 180  # Spread in all directions
		
		#material.color = Color(1.0, 1.0, 1.0, 0.8)  # White particles with slight transparency
		#material.color_ramp = generate_color_ramp()  # Gradient effect

		particles.process_material = material
		# Position particles in the world (adjust as needed)
		  # Change to where you need the effect
		
		add_child(particles)  # Attach to TileMap
func generate_color_ramp():
	var gradient = GradientTexture1D.new()
	gradient.gradient = Gradient.new()
	gradient.gradient.set_color(0, Color(1, 0, 0, 1))  # Red
	gradient.gradient.set_color(1, Color(1, 1, 0, 0))  # Fades to transparent yellow
	return gradient

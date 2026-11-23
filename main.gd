extends Node3D

func _ready() -> void:
	var world := VoxelWorld.new()
	world.name = "World"
	add_child(world)
	world.load_edits()
	world.load_around(Vector3(8, 0, 8), 2)
	var h := world.surface_height(8, 8)
	var player := Player.new()
	player.world = world
	add_child(player)
	player.global_position = Vector3(8.5, h + 2.0, 8.5)
	player.spawn_pos = player.global_position
	world.player = player
	_environment()

func _environment() -> void:
	var env := Environment.new()
	var sky := Sky.new()
	sky.sky_material = ProceduralSkyMaterial.new()
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.fog_enabled = true
	env.fog_density = 0.012
	env.fog_light_color = Color(0.62, 0.66, 0.7)
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, 30, 0)
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 80.0
	add_child(sun)

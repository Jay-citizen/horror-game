class_name Player extends CharacterBody3D
var world: VoxelWorld
var head: Node3D
var cam: Camera3D
var flash: SpotLight3D
var hud: HUD
var highlight: MeshInstance3D
var sens := 0.0025
var pitch := 0.0
var inv := {2: 20, 3: 10, 4: 10, 5: 10, 10: 20, 1: 5, 6: 5, 7: 3, 8: 3}
var hotbar := [1, 2, 3, 4, 5, 6, 10, 7, 8]
var sel := 0
var target := {"hit": false}
var mine_target := Vector3i(0, -999, 0)
var mine_prog := 0.0
var spawn_pos := Vector3.ZERO

func _ready() -> void:
	var cs := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.3
	cap.height = 1.8
	cs.shape = cap
	cs.position.y = 0.9
	add_child(cs)
	head = Node3D.new()
	head.position.y = 1.62
	add_child(head)
	cam = Camera3D.new()
	head.add_child(cam)
	cam.make_current()
	flash = SpotLight3D.new()
	flash.spot_range = 30.0
	flash.spot_angle = 30.0
	flash.light_energy = 3.0
	flash.visible = false
	cam.add_child(flash)
	hud = HUD.new()
	add_child(hud)
	highlight = MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3.ONE * 1.01
	highlight.mesh = bm
	var hm := StandardMaterial3D.new()
	hm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	hm.albedo_color = Color(1, 1, 1, 0.22)
	hm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	highlight.material_override = hm
	highlight.top_level = true
	highlight.visible = false
	highlight.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(highlight)
	spawn_pos = global_position
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(e: InputEvent) -> void:
	var captured := Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	if e is InputEventMouseMotion and captured:
		rotate_y(-e.relative.x * sens)
		pitch = clampf(pitch - e.relative.y * sens, -1.5, 1.5)
		head.rotation.x = pitch
	elif e is InputEventMouseButton and e.pressed:
		if not captured:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			return
		match e.button_index:
			MOUSE_BUTTON_RIGHT: _place()
			MOUSE_BUTTON_WHEEL_UP: sel = (sel + 8) % 9
			MOUSE_BUTTON_WHEEL_DOWN: sel = (sel + 1) % 9
	elif e is InputEventKey and e.pressed and not e.echo:
		if e.keycode >= KEY_1 and e.keycode <= KEY_9:
			sel = e.keycode - KEY_1
		elif e.keycode == KEY_F:
			flash.visible = not flash.visible
		elif e.keycode == KEY_ESCAPE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if captured else Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	var captured := Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	var dir := Vector3.ZERO
	var sprint := false
	var crouch := false
	if captured:
		var ix := int(Input.is_physical_key_pressed(KEY_D)) - int(Input.is_physical_key_pressed(KEY_A))
		var iz := int(Input.is_physical_key_pressed(KEY_S)) - int(Input.is_physical_key_pressed(KEY_W))
		dir = (transform.basis * Vector3(ix, 0, iz)).normalized()
		sprint = Input.is_physical_key_pressed(KEY_SHIFT)
		crouch = Input.is_physical_key_pressed(KEY_CTRL)
	var speed := 4.5
	if sprint and not crouch: speed = 7.5
	if crouch: speed = 2.2
	head.position.y = lerpf(head.position.y, 1.25 if crouch else 1.62, 12.0 * delta)
	velocity.x = move_toward(velocity.x, dir.x * speed, 40.0 * delta)
	velocity.z = move_toward(velocity.z, dir.z * speed, 40.0 * delta)
	if not is_on_floor():
		velocity.y -= 24.0 * delta
	elif captured and Input.is_physical_key_pressed(KEY_SPACE):
		velocity.y = 8.0
	move_and_slide()
	if global_position.y < -20.0:
		global_position = spawn_pos
		velocity = Vector3.ZERO
	_target_and_mine(delta, captured)
	hud.refresh(sel, hotbar, inv, mine_prog)

func _target_and_mine(delta: float, captured: bool) -> void:
	target = world.raycast(head.global_position, -head.global_transform.basis.z, 5.0)
	highlight.visible = target.hit
	if not target.hit:
		mine_prog = 0.0
		return
	var p: Vector3i = target.pos
	highlight.global_position = Vector3(p) + Vector3(0.5, 0.5, 0.5)
	highlight.global_rotation = Vector3.ZERO
	if captured and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and p.y > 0:
		if p != mine_target:
			mine_target = p
			mine_prog = 0.0
		var id := world.get_blockv(p)
		mine_prog += delta / float(Blocks.DATA[id]["time"])
		if mine_prog >= 1.0:
			var drop: int = Blocks.DATA[id]["drop"]
			inv[drop] = inv.get(drop, 0) + 1
			world.set_blockv(p, 0)
			mine_prog = 0.0
	else:
		mine_prog = 0.0
		mine_target = Vector3i(0, -999, 0)

func _place() -> void:
	if not target.hit:
		return
	var id: int = hotbar[sel]
	if inv.get(id, 0) <= 0:
		return
	var pp: Vector3i = target.prev
	if world.get_blockv(pp) != 0:
		return
	var player_box := AABB(global_position + Vector3(-0.3, 0, -0.3), Vector3(0.6, 1.8, 0.6))
	if player_box.intersects(AABB(Vector3(pp), Vector3.ONE)):
		return
	world.set_blockv(pp, id)
	inv[id] -= 1

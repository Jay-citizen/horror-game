class_name VoxelWorld extends Node3D
const SAVE_PATH := "user://world_edits.dat"
var chunks := {}            # Vector2i -> Chunk
var edits := {}             # Vector2i -> {block index: id}  (chunk-based save data)
var edits_dirty := false
var dirty: Array[Vector2i] = []
var radius := 4
var player: Node3D
var material: StandardMaterial3D
var noise := FastNoiseLite.new()
var cave_noise := FastNoiseLite.new()
var save_t := 0.0

func _init() -> void:
	material = StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.roughness = 1.0
	noise.seed = 1337
	noise.frequency = 0.015
	noise.fractal_octaves = 3
	cave_noise.seed = 4242
	cave_noise.frequency = 0.06

func get_block(x: int, y: int, z: int) -> int:
	if y < 0:
		return Blocks.STONE
	if y >= Chunk.HEIGHT:
		return 0
	var ch: Chunk = chunks.get(Vector2i(floori(x / 16.0), floori(z / 16.0)))
	if ch == null:
		return 0
	return ch.blocks[ch.idx(posmod(x, 16), y, posmod(z, 16))]

func get_blockv(p: Vector3i) -> int:
	return get_block(p.x, p.y, p.z)

func set_blockv(p: Vector3i, id: int) -> void:
	set_block(p.x, p.y, p.z, id)

func set_block(x: int, y: int, z: int, id: int) -> void:
	if y < 0 or y >= Chunk.HEIGHT:
		return
	var c := Vector2i(floori(x / 16.0), floori(z / 16.0))
	var ch: Chunk = chunks.get(c)
	if ch == null:
		return
	var lx := posmod(x, 16)
	var lz := posmod(z, 16)
	var i := ch.idx(lx, y, lz)
	ch.blocks[i] = id
	if not edits.has(c):
		edits[c] = {}
	edits[c][i] = id
	edits_dirty = true
	ch.rebuild()
	if lx == 0: _rebuild_at(c + Vector2i(-1, 0))
	if lx == 15: _rebuild_at(c + Vector2i(1, 0))
	if lz == 0: _rebuild_at(c + Vector2i(0, -1))
	if lz == 15: _rebuild_at(c + Vector2i(0, 1))

func _rebuild_at(c: Vector2i) -> void:
	if chunks.has(c):
		chunks[c].rebuild()

func surface_height(x: int, z: int) -> int:
	for y in range(Chunk.HEIGHT - 1, -1, -1):
		if get_block(x, y, z) != 0:
			return y
	return 0

func spawn_chunk(c: Vector2i) -> void:
	var ch := Chunk.new()
	ch.setup(c, self)
	add_child(ch)
	chunks[c] = ch
	ch.generate()
	ch.rebuild()
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		if chunks.has(c + d) and not dirty.has(c + d):
			dirty.append(c + d)

func load_around(pos: Vector3, r: int) -> void:
	var pc := Vector2i(floori(pos.x / 16.0), floori(pos.z / 16.0))
	for dx in range(-r, r + 1):
		for dz in range(-r, r + 1):
			if not chunks.has(pc + Vector2i(dx, dz)):
				spawn_chunk(pc + Vector2i(dx, dz))

func _process(delta: float) -> void:
	save_t += delta
	if save_t > 20.0:
		save_t = 0.0
		save_edits()
	if player == null:
		return
	var pc := Vector2i(floori(player.global_position.x / 16.0), floori(player.global_position.z / 16.0))
	if not dirty.is_empty():
		_rebuild_at(dirty.pop_front())
		return
	var best := Vector2i.ZERO
	var bd := 1000000
	for dx in range(-radius, radius + 1):
		for dz in range(-radius, radius + 1):
			var d := dx * dx + dz * dz
			if d <= radius * radius and d < bd and not chunks.has(pc + Vector2i(dx, dz)):
				bd = d
				best = pc + Vector2i(dx, dz)
	if bd < 1000000:
		spawn_chunk(best)
	for c in chunks.keys():
		if absi(c.x - pc.x) > radius + 2 or absi(c.y - pc.y) > radius + 2:
			chunks[c].queue_free()
			chunks.erase(c)

# Voxel DDA raycast. Returns {hit, pos, prev}.
func raycast(o: Vector3, d: Vector3, max_dist: float) -> Dictionary:
	var p := Vector3i(floori(o.x), floori(o.y), floori(o.z))
	var prev := p
	var step := Vector3i(1 if d.x > 0 else -1, 1 if d.y > 0 else -1, 1 if d.z > 0 else -1)
	var tmax := Vector3(INF, INF, INF)
	var tdelta := Vector3(INF, INF, INF)
	for a in 3:
		if d[a] != 0.0:
			tdelta[a] = absf(1.0 / d[a])
			var nxt: float = (p[a] + 1 - o[a]) if d[a] > 0 else (o[a] - p[a])
			tmax[a] = nxt * tdelta[a]
	for i in 100:
		if get_blockv(p) != 0:
			return {"hit": true, "pos": p, "prev": prev}
		prev = p
		var ax := 0
		if tmax.y < tmax[ax]: ax = 1
		if tmax.z < tmax[ax]: ax = 2
		if tmax[ax] > max_dist:
			break
		p[ax] += step[ax]
		tmax[ax] += tdelta[ax]
	return {"hit": false}

func save_edits() -> void:
	if not edits_dirty:
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_var(edits)
		edits_dirty = false

func load_edits() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
		var d = f.get_var()
		if d is Dictionary:
			edits = d

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		save_edits()

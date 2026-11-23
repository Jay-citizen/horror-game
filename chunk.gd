class_name Chunk extends Node3D
const SIZE := 16
const HEIGHT := 48
# [normal, origin, u, v, shade]; u x v = -normal (Godot front faces are clockwise)
const FACES := [
	[Vector3i(0, 1, 0), Vector3(0, 1, 0), Vector3(1, 0, 0), Vector3(0, 0, 1), 1.0],
	[Vector3i(0, -1, 0), Vector3(0, 0, 0), Vector3(0, 0, 1), Vector3(1, 0, 0), 0.5],
	[Vector3i(1, 0, 0), Vector3(1, 0, 0), Vector3(0, 0, 1), Vector3(0, 1, 0), 0.8],
	[Vector3i(-1, 0, 0), Vector3(0, 0, 0), Vector3(0, 1, 0), Vector3(0, 0, 1), 0.8],
	[Vector3i(0, 0, 1), Vector3(0, 0, 1), Vector3(0, 1, 0), Vector3(1, 0, 0), 0.65],
	[Vector3i(0, 0, -1), Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(0, 1, 0), 0.65],
]
var coord: Vector2i
var world: VoxelWorld
var blocks := PackedByteArray()
var mesh_inst: MeshInstance3D
var col: CollisionShape3D

func setup(c: Vector2i, w: VoxelWorld) -> void:
	coord = c
	world = w
	position = Vector3(c.x * SIZE, 0, c.y * SIZE)
	mesh_inst = MeshInstance3D.new()
	mesh_inst.material_override = w.material
	add_child(mesh_inst)
	var body := StaticBody3D.new()
	col = CollisionShape3D.new()
	body.add_child(col)
	add_child(body)

func idx(x: int, y: int, z: int) -> int:
	return (y * SIZE + z) * SIZE + x

func get_local(x: int, y: int, z: int) -> int:
	if y < 0:
		return Blocks.STONE
	if y >= HEIGHT:
		return 0
	if x < 0 or x >= SIZE or z < 0 or z >= SIZE:
		return world.get_block(coord.x * SIZE + x, y, coord.y * SIZE + z)
	return blocks[idx(x, y, z)]

func generate() -> void:
	blocks.resize(SIZE * HEIGHT * SIZE)
	blocks.fill(0)
	for x in SIZE:
		for z in SIZE:
			var wx := coord.x * SIZE + x
			var wz := coord.y * SIZE + z
			var h := clampi(int(20.0 + world.noise.get_noise_2d(wx, wz) * 10.0), 4, HEIGHT - 12)
			var beach := h <= 17
			for y in range(0, h + 1):
				var id: int = Blocks.STONE
				if y == h:
					id = Blocks.SAND if beach else Blocks.GRASS
				elif y >= h - 3:
					id = Blocks.SAND if beach else Blocks.DIRT
				else:
					var r := absi(hash(Vector3i(wx, y, wz))) % 200
					if r < 4:
						id = Blocks.COAL
					elif r == 4 and y < h - 8:
						id = Blocks.IRON
					elif r == 5 and y < h - 10:
						id = Blocks.COPPER
					if y > 2 and y < h - 4 and world.cave_noise.get_noise_3d(wx, y, wz) > 0.45:
						id = Blocks.AIR
				blocks[idx(x, y, z)] = id
			if not beach and x >= 2 and x <= 13 and z >= 2 and z <= 13 and absi(hash(Vector2i(wx, wz))) % 70 == 0:
				_tree(x, h, z)
	var e: Dictionary = world.edits.get(coord, {})
	for k in e:
		blocks[k] = e[k]

func _tree(x: int, h: int, z: int) -> void:
	for ty in range(1, 6):
		blocks[idx(x, h + ty, z)] = Blocks.WOOD
	for dx in range(-2, 3):
		for dz in range(-2, 3):
			for dy in range(4, 7):
				if dy == 6 and (absi(dx) == 2 or absi(dz) == 2):
					continue
				var i := idx(x + dx, h + dy, z + dz)
				if blocks[i] == 0:
					blocks[i] = Blocks.LEAVES

func rebuild() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var any := false
	for y in HEIGHT:
		for z in SIZE:
			for x in SIZE:
				var id: int = blocks[idx(x, y, z)]
				if id == 0:
					continue
				var base: Color = Blocks.DATA[id]["color"]
				var jit := 0.9 + float(absi(hash(Vector3i(coord.x * SIZE + x, y, coord.y * SIZE + z))) % 16) / 100.0
				for f in FACES:
					var nb: Vector3i = f[0]
					if get_local(x + nb.x, y + nb.y, z + nb.z) != 0:
						continue
					var c: Color = base * (f[4] * jit)
					c.a = 1.0
					var o: Vector3 = Vector3(x, y, z) + f[1]
					var u: Vector3 = f[2]
					var v: Vector3 = f[3]
					var vs := [o, o + u, o + u + v, o + v]
					for i in [0, 1, 2, 0, 2, 3]:
						st.set_color(c)
						st.set_normal(Vector3(nb))
						st.add_vertex(vs[i])
					any = true
	if any:
		var mesh := st.commit()
		mesh_inst.mesh = mesh
		col.shape = mesh.create_trimesh_shape()
	else:
		mesh_inst.mesh = null
		col.shape = null

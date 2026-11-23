class_name HUD extends CanvasLayer
var slots: Array[Label] = []
var bar: ProgressBar

func _ready() -> void:
	var cross := Label.new()
	cross.text = "+"
	cross.custom_minimum_size = Vector2(24, 24)
	cross.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cross.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(cross)
	cross.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	bar = ProgressBar.new()
	bar.custom_minimum_size = Vector2(120, 8)
	bar.show_percentage = false
	bar.max_value = 1.0
	add_child(bar)
	bar.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	bar.offset_top += 34
	bar.offset_bottom += 34
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	add_child(box)
	for i in 9:
		var l := Label.new()
		l.custom_minimum_size = Vector2(72, 52)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		box.add_child(l)
		slots.append(l)
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	box.grow_vertical = Control.GROW_DIRECTION_BEGIN
	box.offset_bottom = -12
	var help := Label.new()
	help.text = "WASD move  Shift sprint  Ctrl crouch  Space jump  LMB mine  RMB place  1-9/wheel select  F flashlight  Esc mouse"
	help.position = Vector2(10, 8)
	help.modulate = Color(1, 1, 1, 0.6)
	add_child(help)

func refresh(sel: int, hotbar: Array, inv: Dictionary, prog: float) -> void:
	bar.value = prog
	bar.visible = prog > 0.0
	for i in 9:
		var id: int = hotbar[i]
		slots[i].text = "%s\n%d" % [Blocks.DATA[id]["name"], inv.get(id, 0)]
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.9, 0.9, 0.9, 0.35) if i == sel else Color(0, 0, 0, 0.55)
		sb.set_border_width_all(2)
		sb.border_color = Color(1, 1, 1, 0.8) if i == sel else Color(1, 1, 1, 0.15)
		slots[i].add_theme_stylebox_override("normal", sb)

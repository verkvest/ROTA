extends CanvasLayer

@onready var control := $Control
@onready var right := $Control/HBoxRight
@onready var top := $Control/HBoxTop

@onready var keys := [$Control/HBoxRight/C, $Control/HBoxRight/X]
@onready var buttons := [$Control/HBoxRight/C/Control/Button, $Control/HBoxRight/X/Control/Button]

@onready var key_z := $Control/HBoxTop/Z
@onready var pause := $Control/HBoxTop/Pause
@onready var game_hide := [$Control/HBoxRight/C/Control/Key, $Control/HBoxRight/X/Control/Key]
@onready var game_show := [key_z, $Control/HBoxRight/C/Control/Sprite2D, $Control/HBoxRight/X/Control/Sprite2D]

@onready var btns := $Control/HBoxLeft/DPad/Buttons.get_children()
@onready var actions := InputMap.get_actions()

func _ready():
	set_game(false)
	visible = false
	margin(Shared.margin_x, Shared.margin_y)
	get_viewport().size_changed.connect(_on_viewport_resized)
	
	await Shared.scene_changed
	visible = _wants_touch()

func _wants_touch() -> bool:
	if Shared.is_touch:
		return true
	var os_name := OS.get_name()
	if os_name == "Android" or os_name == "iOS" or OS.has_feature("mobile"):
		return true
	if DisplayServer.is_touchscreen_available() and os_name == "Web":
		return true
	return false

func _on_viewport_resized():
	margin(Shared.margin_x, Shared.margin_y)

func _input(event):
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		visible = true
	elif event is InputEventKey or event is InputEventJoypadButton or event is InputEventJoypadMotion:
		visible = Shared.is_touch

func show_keys(arg_arrows := true, arg_c := true, arg_x := true, arg_pause := false, arg_passby := false):
	right.visible = arg_arrows
	keys[0].visible = arg_c
	keys[1].visible = arg_x
	top.visible = arg_pause

func set_game(arg := false):
	
	for h in game_hide:
		h.visible = !arg
	for s in game_show:
		s.visible = arg
	
	if Shared.is_arcade:
		key_z.visible = false
	pause.visible = !Shared.is_title
	
	for a in actions:
		Input.action_release(a)
	
	for f in buttons:
		f.passby_press = arg

func margin(x := 20, y := 20):
	var left := float(x)
	var top := float(y)
	var right := float(x)
	var bottom := float(y)
	var win := Vector2(DisplayServer.window_get_size())
	if win.x > 1.0 and win.y > 1.0 and control:
		var safe := DisplayServer.get_display_safe_area()
		var vp := get_viewport().get_visible_rect().size
		var sx := vp.x / win.x
		var sy := vp.y / win.y
		left = max(left, safe.position.x * sx)
		top = max(top, safe.position.y * sy)
		right = max(right, (win.x - safe.end.x) * sx)
		bottom = max(bottom, (win.y - safe.end.y) * sy)
	if control:
		control.offset_left = left
		control.offset_right = -right
		control.offset_top = top
		control.offset_bottom = -bottom

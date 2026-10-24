extends MenuBase

@export var sub_path : NodePath
@onready var file_menu = get_node_or_null(sub_path)

@export var credits_path : NodePath
@onready var credits_menu = get_node_or_null(credits_path)

@export var licenses_path : NodePath
@onready var licenses_menu = get_node_or_null(licenses_path)

var pos = Vector2(1800, 650)

func _ready():
	if OS.get_name() == "iOS":
		var quit_item := get_node_or_null("List/Exit")
		if quit_item:
			quit_item.visible = false
	super._ready()

func accept():
	match items[cursor].name.to_lower():
		"play":
			sub_menu(file_menu)
			Cam.target_pos = pos + Vector2(350, 0)
		"makeover":
			sub_menu(MenuMakeover)
		"options":
			sub_menu(MenuOptions)
			Cam.target_pos = pos + Vector2(0, -600)
		"credits":
			sub_menu(credits_menu)
			Cam.target_pos = pos + Vector2(350, 0)
		"licenses":
			sub_menu(licenses_menu)
		"exit":
			Shared.quit()

func open():
	Cam.target_pos = pos - Vector2(150, 0)
	Cam.turn(0)

func close():
	Cam.target_pos = pos


extends MenuBase

@onready var body: RichTextLabel = $Body

func _ready():
	var notice := "res://THIRD_PARTY_LICENSES.md"
	if FileAccess.file_exists(notice):
		body.text = FileAccess.get_file_as_string(notice)
	else:
		body.text = "License text is missing from this build."
	super._ready()

func menu_process(delta):
	super.menu_process(delta)
	if is_open and body:
		var bar := body.get_v_scroll_bar()
		bar.value += Input.get_axis("ui_up", "ui_down") * 900.0 * delta

extends Node

func _ready():
	await get_tree().process_frame
	if "--phone-shot" in OS.get_cmdline_user_args():
		DisplayServer.window_set_size(Vector2i(1280, 720))
		RenderingServer.canvas_set_shadow_texture_size(1024)
		Shared.begin_phone_shots(_shot_dir())
		return
	$AudioStreamPlayer.play()
	await get_tree().create_timer(1.25).timeout
	Shared.wipe_scene(Shared.title_path)

func _shot_dir() -> String:
	for arg in OS.get_cmdline_user_args():
		if str(arg).begins_with("--shot-dir="):
			return str(arg).trim_prefix("--shot-dir=")
	return "user://shots"

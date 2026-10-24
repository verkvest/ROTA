@tool
extends TileMap

var spike_scene = preload("res://src/actor/Spike.tscn")

var spikes = {}

func _ready():
	await get_parent().ready
	make_tiles()

func place_cell(x, y, tile, flip_x := false, flip_y := false, transpose := false):
	var coords := Vector2i(int(x), int(y))
	if int(tile) < 0:
		erase_cell(0, coords)
	else:
		set_cell(0, coords, int(tile), Vector2i.ZERO, _alt(flip_x, flip_y, transpose))
	remove_spike(coords.x, coords.y)
	if int(tile) == 0:
		set_spike(coords)

func _alt(flip_x, flip_y, transpose) -> int:
	var alt := 0
	if flip_x:
		alt |= TileSetAtlasSource.TRANSFORM_FLIP_H
	if flip_y:
		alt |= TileSetAtlasSource.TRANSFORM_FLIP_V
	if transpose:
		alt |= TileSetAtlasSource.TRANSFORM_TRANSPOSE
	return alt

func rot(vec = Vector2.ZERO, dir = 0):
	return vec.rotated(deg_to_rad(dir * 90)).round()

func make_tiles():
	spikes = {}
	for i in get_children():
		i.queue_free()
	for i in get_used_cells(0):
		set_spike(i)

func remove_spike(x: int, y: int):
	var key = str(x) + "," + str(y)
	if spikes.has(key) and is_instance_valid(spikes[key]):
		spikes[key].queue_free()
		spikes.erase(key)

func set_spike(i):
	var s = spike_scene.instantiate()
	add_child(s)
	var v := Vector2(i)
	spikes[str(int(v.x)) + "," + str(int(v.y))] = s
	var cs := Vector2(tile_set.tile_size)
	s.position = (v + Vector2.ONE / 2.0) * cs
	var alt := get_cell_alternative_tile(0, Vector2i(v))
	var transposed = bool(alt & TileSetAtlasSource.TRANSFORM_TRANSPOSE)
	var flipped_y = bool(alt & TileSetAtlasSource.TRANSFORM_FLIP_V)
	if transposed and flipped_y:
		s.dir = 3
	elif transposed:
		s.dir = 1
	elif flipped_y:
		s.dir = 2

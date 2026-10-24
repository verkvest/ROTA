@tool
extends TileMap

@onready var auto: TileMap = get_child(0)
@export var detail := 0: set = set_detail

var sets = [
	preload("res://src/stage/tileset/TileSet0.tres"),
	preload("res://src/stage/tileset/TileSet1.tres"),
	preload("res://src/stage/tileset/TileSet2.tres"),
	preload("res://src/stage/tileset/TileSet3.tres"),
	preload("res://src/stage/tileset/TileSet4.tres"),
	preload("res://src/stage/tileset/TileSet5.tres"),
	preload("res://src/stage/tileset/TileSet6.tres"),
]

func _ready():
	set_detail()
	make_tiles()

func set_detail(arg := detail):
	detail = posmod(int(arg), sets.size())
	if auto and detail < sets.size():
		if sets[detail] is TileSet:
			auto.tile_set = sets[detail]
			auto.queue_redraw()

func place_cell(x, y, tile, flip_x := false, flip_y := false, transpose := false):
	var coords := Vector2i(int(x), int(y))
	if int(tile) < 0:
		erase_cell(0, coords)
	else:
		set_cell(0, coords, int(tile), Vector2i.ZERO, _alt(flip_x, flip_y, transpose))
	var n = 1 if Engine.is_editor_hint() else 2
	for _x in range(coords.x - n, coords.x + n):
		for _y in range(coords.y - n, coords.y + n):
			set_tile(_x, _y)

func _alt(flip_x, flip_y, transpose) -> int:
	var alt := 0
	if flip_x:
		alt |= TileSetAtlasSource.TRANSFORM_FLIP_H
	if flip_y:
		alt |= TileSetAtlasSource.TRANSFORM_FLIP_V
	if transpose:
		alt |= TileSetAtlasSource.TRANSFORM_TRANSPOSE
	return alt

func make_tiles():
	if auto == null:
		auto = get_child(0)
	auto.clear()
	var r := get_used_rect()
	for x in range(r.position.x - 1, r.position.x + r.size.x + 1):
		for y in range(r.position.y - 1, r.position.y + r.size.y + 1):
			set_tile(x, y)

func occupied(x: int, y: int) -> bool:
	return get_cell_source_id(0, Vector2i(x, y)) != -1

func set_tile(x: int, y: int):
	var up_left = int(occupied(x, y))
	var up_right = int(occupied(x + 1, y))
	var down_right = int(occupied(x + 1, y + 1))
	var down_left = int(occupied(x, y + 1))
	var tile_value = up_left + (up_right * 2) + (down_right * 4) + (down_left * 8)

	var tile = -1
	var fx := false
	var fy := false
	var tr := false

	var solid = 0
	var corner = 1
	var flat = 2
	var inside = 3
	var meeting = 4

	match tile_value:
		1:
			tile = corner
			fx = true
			fy = true
		2:
			tile = corner
			fy = true
		3:
			tile = flat
			fy = true
		4:
			tile = corner
		5:
			tile = meeting
			fx = true
		6:
			tile = flat
			tr = true
			fy = true
		7:
			tile = inside
			fy = true
		8:
			tile = corner
			fx = true
		9:
			tile = flat
			tr = true
			fx = true
		10:
			tile = meeting
		11:
			tile = inside
			fx = true
			fy = true
		12:
			tile = flat
		13:
			tile = inside
			fx = true
		14:
			tile = inside
		15:
			tile = solid

	if auto == null:
		auto = get_child(0)
	var coords := Vector2i(x, y)
	if tile < 0:
		auto.erase_cell(0, coords)
	else:
		auto.set_cell(0, coords, tile, Vector2i.ZERO, _alt(fx, fy, tr))

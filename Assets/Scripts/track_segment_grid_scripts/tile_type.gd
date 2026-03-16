extends RefCounted
class_name TileType

var tile_type_id: int
var tile_id: int

var direction_maps: Array[Dictionary] = []

func _init(init_tile_type_id: int, init_tile_id: int, init_direction_maps: Array[Dictionary]) -> void:
    tile_type_id = init_tile_type_id
    tile_id = init_tile_id

    direction_maps = init_direction_maps

    


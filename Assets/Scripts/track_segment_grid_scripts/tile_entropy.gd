extends RefCounted
class_name TileEntropy

var location: Vector2i
var valid_tile_types: Array[TileType]

func _init(init_location: Vector2i, init_valid_tile_types: Array[TileType]):
    location = init_location
    valid_tile_types = init_valid_tile_types
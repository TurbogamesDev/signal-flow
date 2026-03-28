extends RefCounted
class_name TileEntropy

var location: Vector2i
var valid_tile_types: Array[TileType]

var tile_already_collapsed: bool = false

func _init(init_location: Vector2i, init_valid_tile_types: Array[TileType]) -> void:
	self.location = init_location
	self.valid_tile_types = init_valid_tile_types

func is_equal(other_tile_entropy: TileEntropy) -> bool:
	return self.valid_tile_types == other_tile_entropy.valid_tile_types

func get_entropy_count() -> int:
	if tile_already_collapsed:
		return -1

	return len(self.valid_tile_types)


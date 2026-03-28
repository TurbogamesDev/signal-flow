extends RefCounted
class_name TileType

var tile_type_id: int
var tile_id: int

var direction_maps: Array[Dictionary] = []

var resource_path: String = ""

func _init(init_tile_type_id: int, init_tile_id: int, init_direction_maps: Array[Dictionary], init_resource_path: String) -> void:
	self.tile_type_id = init_tile_type_id
	self.tile_id = init_tile_id

	self.direction_maps = init_direction_maps

	self.resource_path = init_resource_path

	# print(resource_path)

func is_equal(other_tile_type: TileType) -> bool:
	return (self.tile_type_id == other_tile_type.tile_type_id) and (self.tile_id == other_tile_type.tile_id)

	


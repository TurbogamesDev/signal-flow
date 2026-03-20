extends RefCounted
class_name TileInstance

# var direction_maps: Array[Dictionary] = []
var segment: BaseTrainTrackSegment
var location: Vector2i

var tile_type: TileType

func _init(init_tile_type: TileType, init_segment: BaseTrainTrackSegment, init_location: Vector2i) -> void:
    self.tile_type = init_tile_type

    self.segment = init_segment
    self.location = init_location
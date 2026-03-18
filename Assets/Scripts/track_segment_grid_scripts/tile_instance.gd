extends RefCounted
class_name TileInstance

# var direction_maps: Array[Dictionary] = []
var segment: BaseTrainTrackSegment
var location: Vector2i

var tile_type: TileType

func _init(init_tile_type: TileType, init_segment: BaseTrainTrackSegment, init_location: Vector2i):
    tile_type = init_tile_type

    segment = init_segment
    location = init_location
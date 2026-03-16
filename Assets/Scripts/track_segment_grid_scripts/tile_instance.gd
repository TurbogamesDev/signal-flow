extends RefCounted
class_name TileInstance

var direction_maps: Array[Dictionary] = []
var segment: BaseTrainTrackSegment
var location: Vector2i

func _init(init_direction_maps: Array[Dictionary], init_segment: BaseTrainTrackSegment, init_location: Vector2i):
    direction_maps = init_direction_maps
    segment = init_segment
    location = init_location
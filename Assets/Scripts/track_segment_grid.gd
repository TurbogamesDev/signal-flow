extends TileMapLayer
class_name TrackSegmentGrid





func placeSegment(segment_type: int, segment: int, segment_position: Vector2i):
    self.set_cell(segment_position, segment_type, Vector2i(0, 0), segment)

func _ready() -> void:
    placeSegment(0, 0, Vector2i(0, 0))
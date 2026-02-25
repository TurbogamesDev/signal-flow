extends TileMapLayer
class_name TrackSegmentGrid

func placeSegment(segment_type: Enums.TrackSegmentType, segment: int, segment_position: Vector2i):
    self.set_cell(segment_position, segment_type, Vector2i(0, 0), segment)

func _ready() -> void:
    placeSegment(
        Enums.TrackSegmentType.REGULAR_TRACK_SEGMENT,
        Enums.RegularTrackSegment.EAST_TO_WEST,
        Vector2i(-1, -1)
    )

    placeSegment(
        Enums.TrackSegmentType.SINGULAR_TRACK_SEGMENT, 
        Enums.SingularTrackSegment.HORIZONTAL_FOLLOWING_TO_OPPOSING,
        Vector2i(0, -1)
    )

    placeSegment(
        Enums.TrackSegmentType.STATION_TRACK_SEGMENT,
        Enums.StationTrackSegment.NORTH_ENTRY_TERMINATING,
        Vector2i(-1, 0)
    )

    placeSegment(
        Enums.TrackSegmentType.SWITCHING_TRACK_SEGMENT,
        Enums.SwitchingTrackSegment.EAST_TO_WEST_AND_NORTH_TO_WEST,
        Vector2i(0, 0)
    )
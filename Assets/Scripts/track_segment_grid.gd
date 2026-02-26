extends TileMapLayer
class_name TrackSegmentGrid

var trackSegmentToDirectionMap = {

}

func getDirectionMapsFromPackedScene(packed_scene: PackedScene):
	var return_value: Array[Dictionary] = []

	var track_segment_node = packed_scene.instantiate()
	assert(track_segment_node is BaseTrainTrackSegment)

	var root_direction_map = track_segment_node.get("directionMap")

	if root_direction_map:
		return_value.append(root_direction_map)

		track_segment_node.queue_free()

		return return_value

	var child_track_segments = track_segment_node.get_node("TrainTrackSegments").get_children()
	print(child_track_segments)

	for child in child_track_segments:
		var child_direction_map = child.get("directionMap")

		if child_direction_map:
			return_value.append(child_direction_map)

	track_segment_node.free()

	return return_value

func getDirectionMapsFromSegmentTypeAndSegment(segment_type: Enums.TrackSegmentType, segment: int):
	var tile_set_source: TileSetScenesCollectionSource = tile_set.get_source(segment_type)

	var packed_scene: PackedScene = tile_set_source.get_scene_tile_scene(segment)

	var direction_maps = getDirectionMapsFromPackedScene(packed_scene)

	return direction_maps


func placeSegment(segment_type: Enums.TrackSegmentType, segment: int, segment_position: Vector2i):
	self.set_cell(segment_position, segment_type, Vector2i(0, 0), segment)

func _ready() -> void:
	placeSegment(
		Enums.TrackSegmentType.REGULAR_TRACK_SEGMENT,
		Enums.RegularTrackSegment.EAST_TO_WEST,
		Vector2i(-1, -1)
	)

	print(
		getDirectionMapsFromSegmentTypeAndSegment(
			Enums.TrackSegmentType.SWITCHING_TRACK_SEGMENT,
			Enums.SwitchingTrackSegment.EAST_TO_WEST_AND_NORTH_TO_WEST
		)
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

	# var tile_set_source: TileSetScenesCollectionSource = tile_set.get_source(2)

	# var test_packed_scene: PackedScene = tile_set_source.get_scene_tile_scene(0)  # load("res://Assets/Scenes/Track_Segments/Regular_Track_Segments/Straight_Track_Segments/east_to_west_train_track_segment.tscn")

	# # var test_scene_state: SceneState = test_packed_scene.get_state()

	# print("a")
	# print(
	# 	getDirectionMapsFromPackedScene(test_packed_scene)
	# )

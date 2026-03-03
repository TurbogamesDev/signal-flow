extends TileMapLayer
class_name TrackSegmentGrid

var trackSegmentToDirectionMaps = [] # Array[Array[Dictionary[Enums.TrainDirection, Enums.TrainDirection]]]
var segmentInstances: Dictionary[Vector2i, BaseTrainTrackSegment] = {}

const RELATIVE_POSITION_TO_LOCATION_OFFSET: Dictionary[Enums.RelativePosition, Vector2i] = {
	Enums.RelativePosition.NORTH: Vector2i(0, -1),
	Enums.RelativePosition.SOUTH: Vector2i(0, 1),
	Enums.RelativePosition.EAST: Vector2i(1, 0),
	Enums.RelativePosition.WEST: Vector2i(-1, 0)
}

const RELATIVE_POSITION_TO_SOCKET_DIRECTIONS: Dictionary[Enums.RelativePosition, Array] = {
	Enums.RelativePosition.NORTH: [
		Enums.TrainDirection.NORTH_FOLLOWING,
		Enums.TrainDirection.NORTH_OPPOSING
	],
	Enums.RelativePosition.SOUTH: [
		Enums.TrainDirection.SOUTH_FOLLOWING,
		Enums.TrainDirection.SOUTH_OPPOSING
	],
	Enums.RelativePosition.EAST: [
		Enums.TrainDirection.EAST_FOLLOWING,
		Enums.TrainDirection.EAST_OPPOSING
	],
	Enums.RelativePosition.WEST: [
		Enums.TrainDirection.WEST_FOLLOWING,
		Enums.TrainDirection.WEST_OPPOSING
	]
}

const RELATIVE_POSITION_TO_OPPOSITE_RELATIVE_POSITION: Dictionary[Enums.RelativePosition, Enums.RelativePosition] = {
	Enums.RelativePosition.NORTH: Enums.RelativePosition.SOUTH,
	Enums.RelativePosition.SOUTH: Enums.RelativePosition.NORTH,
	Enums.RelativePosition.EAST: Enums.RelativePosition.WEST,
	Enums.RelativePosition.WEST: Enums.RelativePosition.EAST
}

func getDirectionMapsFromSegment(segment: BaseTrainTrackSegment) -> Array[Dictionary]:
	var return_value: Array[Dictionary] = []

	# var track_segment_node = packed_scene.instantiate()
	# assert(track_segment_node is BaseTrainTrackSegment)

	var root_direction_map = segment.get("directionMap")

	if root_direction_map:
		return_value.append(root_direction_map)

		# return return_value

	var child_track_segments_node = segment.get_node_or_null("TrainTrackSegments")

	if not child_track_segments_node:
		return return_value

	var child_track_segments = child_track_segments_node.get_children()

	for child in child_track_segments:
		var child_direction_map = child.get("directionMap")

		if not child_direction_map:
			continue

		return_value.append(child_direction_map)

	return return_value

func getDirectionMapsFromPackedScene(packed_scene: PackedScene) -> Array[Dictionary]:
	var return_value: Array[Dictionary] = []

	var track_segment_node = packed_scene.instantiate()
	assert(track_segment_node is BaseTrainTrackSegment)

	return_value = getDirectionMapsFromSegment(track_segment_node)

	track_segment_node.queue_free()

	return return_value

func getDirectionMapsFromSegmentTypeAndSegment(segment_type: Enums.TrackSegmentType, segment: int) -> Array[Dictionary]:
	var tile_set_source: TileSetScenesCollectionSource = tile_set.get_source(segment_type)

	var packed_scene: PackedScene = tile_set_source.get_scene_tile_scene(segment)

	var direction_maps = getDirectionMapsFromPackedScene(packed_scene)

	return direction_maps

func loadTrackSegmentToDirectionMaps() -> void:
	var source_count = tile_set.get_source_count()

	for source_id in range(source_count):
		trackSegmentToDirectionMaps.append([])

		var source: TileSetScenesCollectionSource = tile_set.get_source(source_id)

		var scene_count = source.get_scene_tiles_count()

		for scene_id in range(scene_count):
			var direction_maps = getDirectionMapsFromSegmentTypeAndSegment(source_id, scene_id)

			trackSegmentToDirectionMaps[source_id].append(direction_maps)



	

	# for segment_type_name in Enums.TrackSegmentType:
	# 	var segments_list = []

	# 	for segment_id in Enums.TrackSegmentType.values():


func getEntryAndExitSocketsForRelativePosition(direction_maps_1: Array[Dictionary], direction_maps_2: Array[Dictionary], relative_position_of_segment_2_to_segment_1: Enums.RelativePosition) -> Dictionary[String, Array]:
	# var direction_maps_1 = trackSegmentToDirectionMap[segment_1_type][segment_1]
	# var direction_maps_2 = trackSegmentToDirectionMap[segment_2_type][segment_2]
	
	var exit_directions_of_segment_1 = []

	for direction_map in direction_maps_1:
		exit_directions_of_segment_1.append_array(direction_map.values())
	

	var entry_directions_of_segment_2 = []

	for direction_map in direction_maps_2:
		entry_directions_of_segment_2.append_array(direction_map.keys())
	

	var socket_directions = RELATIVE_POSITION_TO_SOCKET_DIRECTIONS[relative_position_of_segment_2_to_segment_1]

	var segment_1_exit_socket = []
	
	for direction in socket_directions:
		if direction in exit_directions_of_segment_1:
			segment_1_exit_socket.append(direction)


	var segment_2_entry_socket = []
	
	for direction in socket_directions:
		if direction in entry_directions_of_segment_2:
			segment_2_entry_socket.append(direction)


	return {
		"segment_1_exit_socket": segment_1_exit_socket,
		"segment_2_entry_socket": segment_2_entry_socket
	}

func checkIfTwoSegmentsAreConnectedOrCompatible(direction_maps_1: Array[Dictionary], direction_maps_2: Array[Dictionary], relative_position_of_segment_2_to_segment_1: Enums.RelativePosition) -> Dictionary[String, bool]:
	var sockets_dict = getEntryAndExitSocketsForRelativePosition(direction_maps_1, direction_maps_2, relative_position_of_segment_2_to_segment_1)

	var segment_1_exit_socket = sockets_dict["segment_1_exit_socket"]
	var segment_2_entry_socket = sockets_dict["segment_2_entry_socket"]

	var compatible: bool = ( (segment_1_exit_socket != []) and (segment_2_entry_socket != []) ) or ((segment_1_exit_socket == []) and (segment_2_entry_socket == []))
	var disconnected: bool = (segment_1_exit_socket == []) or (segment_2_entry_socket == [])

	return {
		"compatible": compatible,
		"connected": compatible and not disconnected
	}


func registerSegment(location: Vector2i, segment: BaseTrainTrackSegment) -> void:
	segmentInstances[location] = segment

	onSegmentRegistration(location, segment)

func onSegmentRegistration(location: Vector2i, segment: BaseTrainTrackSegment):
	updateExitDirectionsOfSegmentAndNeighbours(location, segment)

	if location == Vector2i(0, 1):
		print(getAllSegmentsCompatibleWithDirectionMapsInDirection(getDirectionMapsFromSegment(segment), Enums.RelativePosition.NORTH))

	print("Placed Segment %s at position %s" % [segment.name, location])


func getSegmentsNeighbouringSegmentLocation(location: Vector2i) -> Dictionary[Enums.RelativePosition, BaseTrainTrackSegment]:
	var return_value: Dictionary[Enums.RelativePosition, BaseTrainTrackSegment] = {}

	for relative_position in Enums.RelativePosition.values():
		var location_offset = RELATIVE_POSITION_TO_LOCATION_OFFSET[relative_position]

		var new_location = location + location_offset

		var segment = segmentInstances.get(new_location)

		return_value[relative_position] = segment

	return return_value

func makeSegment2TheExitSegmentOfSegment1(segment_1_scene: BaseTrainTrackSegment, segment_2_scene: BaseTrainTrackSegment, relative_position: Enums.RelativePosition):
	var socket_directions = RELATIVE_POSITION_TO_SOCKET_DIRECTIONS[relative_position]
	
	for socket_direction in socket_directions:
		if not (socket_direction in segment_1_scene.exitDirectionToNextTrainTrackSegmentMap):
			continue
		
		segment_1_scene.exitDirectionToNextTrainTrackSegmentMap[socket_direction] = segment_2_scene

func updateExitDirectionsOfSegmentAndNeighbours(location: Vector2i, segment: BaseTrainTrackSegment):
	var neighbouring_segments = getSegmentsNeighbouringSegmentLocation(location)

	for relative_position in neighbouring_segments:
		var neighbouring_segment = neighbouring_segments[relative_position]

		if not neighbouring_segment:
			continue

		var connected = checkIfTwoSegmentsAreConnectedOrCompatible(
			getDirectionMapsFromSegment(segment),
			getDirectionMapsFromSegment(neighbouring_segment),
			relative_position
		).connected

		if not connected:
			continue


		makeSegment2TheExitSegmentOfSegment1(segment, neighbouring_segment, relative_position)

		makeSegment2TheExitSegmentOfSegment1(neighbouring_segment, segment, RELATIVE_POSITION_TO_OPPOSITE_RELATIVE_POSITION[relative_position])

		
func getAllSegmentsCompatibleWithDirectionMapsInDirection(direction_maps: Array[Dictionary], relative_direction: Enums.RelativePosition) -> Array:
	var segments_compatible = []
	
	for checking_segment_type in range(trackSegmentToDirectionMaps.size()):
		var checking_segments = trackSegmentToDirectionMaps[checking_segment_type]

		for checking_segment in range(checking_segments.size()):
			# print(checking_segments)

			var checking_segment_direction_maps = checking_segments[checking_segment]

			var compatible = checkIfTwoSegmentsAreConnectedOrCompatible(
				direction_maps,
				checking_segment_direction_maps, 
				relative_direction
			).compatible

			if not compatible:
				continue

			segments_compatible.append({
				"segment_type": checking_segment_type,
				"segment": checking_segment
			})

	return segments_compatible

func calculateTileEntropy(location: Vector2i):
	pass


# func checkIfTwoSegmentsAreConnected(segment_1_type: Enums.TrackSegmentType, segment_1: int, segment_2_type: Enums.TrackSegmentType, segment_2: int, relative_position_of_segment_2_to_segment_1: Enums.RelativePosition) -> bool:
# 	var sockets_dict = getEntryAndExitSocketsForRelativePosition(segment_1_type, segment_1, segment_2_type, segment_2, relative_position_of_segment_2_to_segment_1)

# 	var segment_1_exit_socket = sockets_dict["segment_1_exit_socket"]
# 	var segment_2_entry_socket = sockets_dict["segment_2_entry_socket"]

# 	return segment_1_exit_socket == segment_2_entry_socket


func placeSegment(segment_type: Enums.TrackSegmentType, segment: int, segment_position: Vector2i) -> void:
	self.set_cell(segment_position, segment_type, Vector2i(0, 0), segment)

	# var segment_scene = self.tile_map_data


func _ready() -> void:
	loadTrackSegmentToDirectionMaps()

	# print(trackSegmentToDirectionMap)

	# placeSegment(
	# 	Enums.TrackSegmentType.REGULAR_TRACK_SEGMENT,
	# 	Enums.RegularTrackSegment.EAST_TO_WEST,
	# 	Vector2i(-1, -1)
	# )

	# placeSegment(
	# 	Enums.TrackSegmentType.REGULAR_TRACK_SEGMENT,
	# 	Enums.RegularTrackSegment.EAST_TO_WEST,
	# 	Vector2i(0, -1)
	# )

	# var return_dict = checkIfTwoSegmentsAreConnectedOrCompatible(
	# 	Enums.TrackSegmentType.STATION_TRACK_SEGMENT,
	# 	Enums.StationTrackSegment.EAST_ENTRY_TERMINATING,
	# 	Enums.TrackSegmentType.REGULAR_TRACK_SEGMENT,
	# 	Enums.RegularTrackSegment.EAST_TO_WEST,
	# 	Enums.RelativePosition.EAST
	# )

	# print("Compatible: %s, Connected: %s" % [return_dict.compatible, return_dict.connected])

	# placeSegment(
	# 	Enums.TrackSegmentType.REGULAR_TRACK_SEGMENT,
	# 	Enums.RegularTrackSegment.EAST_TO_WEST,
	# 	Vector2i(-1, -1)
	# )

	# print(
	# 	trackSegmentToDirectionMap[Enums.TrackSegmentType.SWITCHING_TRACK_SEGMENT][Enums.SwitchingTrackSegment.EAST_TO_WEST_AND_NORTH_TO_WEST]
	# )

	# placeSegment(
	# 	Enums.TrackSegmentType.SINGULAR_TRACK_SEGMENT, 
	# 	Enums.SingularTrackSegment.HORIZONTAL_FOLLOWING_TO_OPPOSING,
	# 	Vector2i(0, -1)
	# )

	# placeSegment(
	# 	Enums.TrackSegmentType.STATION_TRACK_SEGMENT,
	# 	Enums.StationTrackSegment.NORTH_ENTRY_TERMINATING,
	# 	Vector2i(-1, 0)
	# )

	# placeSegment(
	# 	Enums.TrackSegmentType.SWITCHING_TRACK_SEGMENT,
	# 	Enums.SwitchingTrackSegment.EAST_TO_WEST_AND_NORTH_TO_WEST,
	# 	Vector2i(0, 0)
	# )

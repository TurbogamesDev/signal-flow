extends TileMapLayer
class_name TrackSegmentGrid

var tile_type_lookup_table: Dictionary[Vector2i, TileType] = {}
var tile_instance_lookup_table: Dictionary[Vector2i, TileInstance] = {}
var tile_entropy_lookup_table: Dictionary[Vector2i, TileEntropy] = {}

var default_valid_tile_types: Array[TileType] = [] # performance reasons

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


func get_direction_maps_from_segment(segment: BaseTrainTrackSegment) -> Array[Dictionary]:
	var return_value: Array[Dictionary] = []

	var root_direction_map: Dictionary[Enums.TrainDirection, Enums.TrainDirection] = segment.get("directionMap")

	if root_direction_map:
		return_value.append(root_direction_map)

	var child_track_segments_node: Node2D = segment.get_node_or_null("TrainTrackSegments")

	if not child_track_segments_node:
		return return_value

	var child_track_segments: Array[Node] = child_track_segments_node.get_children()

	for child: Node in child_track_segments:
		var child_direction_map: Dictionary[Enums.TrainDirection, Enums.TrainDirection] = child.get("directionMap")

		if not child_direction_map:
			continue

		return_value.append(child_direction_map)

	return return_value

func get_direction_maps_from_packed_scene(packed_scene: PackedScene) -> Array[Dictionary]:
	var return_value: Array[Dictionary] = []

	var track_segment_node: BaseTrainTrackSegment = packed_scene.instantiate()

	return_value = get_direction_maps_from_segment(track_segment_node)

	track_segment_node.queue_free()

	return return_value

func get_packed_scene_from_tile_id_pair(tile_id_pair: Vector2i) -> PackedScene:
	var tile_set_source: TileSetScenesCollectionSource = tile_set.get_source(tile_id_pair.x)

	var packed_scene: PackedScene = tile_set_source.get_scene_tile_scene(tile_id_pair.y)

	return packed_scene



func register_segment(location: Vector2i, segment: BaseTrainTrackSegment) -> void:
	var tile_id_pair: Vector2i = find_tile_id_pair_from_segment(segment)
	
	var tile_instance: TileInstance = TileInstance.new(
		tile_type_lookup_table[tile_id_pair],
		segment,
		location
	)

	tile_instance_lookup_table[location] = tile_instance

	on_segment_registration(location, tile_instance)


func on_segment_registration(location: Vector2i, tile_instance: TileInstance) -> void:
	update_exit_direction_of_tile_instance_and_neighbours(tile_instance)

	trigger_entropy_calculation(location)

	# print("Placed Segment %s at position %s" % [segment.name, location])



func find_tile_id_pair_from_segment(segment: BaseTrainTrackSegment) -> Vector2i:
	var segment_scene_path: String = segment.scene_file_path

	# print(tile_type_lookup_table)

	for tile_id_pair: Vector2i in tile_type_lookup_table.keys():
		var tile_type: TileType = tile_type_lookup_table[tile_id_pair]
		# print("Scene Path is %s and Resource Path is %s" % [segment_scene_path, tile_type.resource_path])

		if tile_type.resource_path == segment_scene_path:
			# print("FOUND!")

			return tile_id_pair

	return Vector2i(-1, -1)

func get_tile_instances_neighbouring_location(location: Vector2i) -> Dictionary[Enums.RelativePosition, TileInstance]:
	var return_value: Dictionary[Enums.RelativePosition, TileInstance] = {}

	for relative_position: Enums.RelativePosition in Enums.RelativePosition.values():
		var location_offset: Vector2i = RELATIVE_POSITION_TO_LOCATION_OFFSET[relative_position]

		var new_location: Vector2i = location + location_offset

		var tile_instance: TileInstance = tile_instance_lookup_table.get(new_location)

		return_value[relative_position] = tile_instance

	return return_value

func make_tile_instance_2_as_exit_segment_of_tile_instance_1(tile_instance_1: TileInstance, tile_instance_2: TileInstance, relative_position: Enums.RelativePosition) -> void:
	var socket_directions: Array = RELATIVE_POSITION_TO_SOCKET_DIRECTIONS[relative_position]
	
	var exit_direction_to_next_train_track_segment_map: Dictionary[Enums.TrainDirection, BaseTrainTrackSegment] = tile_instance_1.segment.exitDirectionToNextTrainTrackSegmentMap

	for socket_direction: Enums.TrainDirection in socket_directions:
		if not (socket_direction in exit_direction_to_next_train_track_segment_map):
			continue
		
		exit_direction_to_next_train_track_segment_map[socket_direction] = tile_instance_2.segment

func update_exit_direction_of_tile_instance_and_neighbours(tile_instance: TileInstance) -> void:
	var neighbouring_tile_instances: Dictionary[Enums.RelativePosition, TileInstance] = get_tile_instances_neighbouring_location(tile_instance.location)

	for relative_position: Enums.RelativePosition in neighbouring_tile_instances:
		var neighbouring_tile_instance: TileInstance = neighbouring_tile_instances[relative_position]

		if not neighbouring_tile_instance:
			continue

		var connected: bool = check_if_tile_types_compatible_or_connected(
			tile_instance.tile_type,
			neighbouring_tile_instance.tile_type,
			relative_position,
			true
		)

		if not connected:
			continue

		make_tile_instance_2_as_exit_segment_of_tile_instance_1(tile_instance, neighbouring_tile_instance, relative_position)
		make_tile_instance_2_as_exit_segment_of_tile_instance_1(neighbouring_tile_instance, tile_instance, RELATIVE_POSITION_TO_OPPOSITE_RELATIVE_POSITION[relative_position])



func load_tile_type_lookup_table() -> void:
	var source_count: int = tile_set.get_source_count()

	for source_id: int in range(source_count):
		var source: TileSetScenesCollectionSource = tile_set.get_source(source_id)

		var scene_count: int = source.get_scene_tiles_count()

		for scene_id: int in range(scene_count):
			var tile_packed_scene: PackedScene = get_packed_scene_from_tile_id_pair(
				Vector2i(source_id, scene_id)
			)

			var direction_maps: Array[Dictionary] = get_direction_maps_from_packed_scene(
				tile_packed_scene
			)

			var tile_resource_path: String = tile_packed_scene.resource_path

			tile_type_lookup_table[
				Vector2i(source_id, scene_id)
			] = TileType.new(source_id, scene_id, direction_maps, tile_resource_path)

func initialise_default_valid_tile_types() -> void:
	default_valid_tile_types = tile_type_lookup_table.values()



func get_socket_for_relative_position_from_tile_type(tile_type: TileType, relative_position: Enums.RelativePosition, exit_socket: bool) -> Array[Enums.TrainDirection]:
	var entry_or_exit_directions: Array[Enums.TrainDirection] = []

	for direction_map: Dictionary in tile_type.direction_maps:
		entry_or_exit_directions.append_array(
			direction_map.values() if exit_socket else direction_map.keys()
		)

	var socket_directions: Array = RELATIVE_POSITION_TO_SOCKET_DIRECTIONS[relative_position]

	var entry_or_exit_socket: Array[Enums.TrainDirection] = []

	for direction: Enums.TrainDirection in socket_directions:
		if direction not in entry_or_exit_directions:
			continue
		
		entry_or_exit_socket.append(direction)

	return entry_or_exit_socket

func check_if_tile_types_compatible_or_connected(tile_type_1: TileType, tile_type_2: TileType, relative_position: Enums.RelativePosition, get_connection_status: bool) -> bool:
	var segment_1_exit_socket: Array[Enums.TrainDirection] = get_socket_for_relative_position_from_tile_type(
		tile_type_1, 
		relative_position, 
		true
	)

	var segment_2_entry_socket: Array[Enums.TrainDirection] = get_socket_for_relative_position_from_tile_type(
		tile_type_2, 
		relative_position, 
		false
	)

	var compatible: bool = ( (segment_1_exit_socket != []) and (segment_2_entry_socket != []) ) or ((segment_1_exit_socket == []) and (segment_2_entry_socket == []))
	
	var disconnected: bool = (segment_1_exit_socket == []) or (segment_2_entry_socket == [])

	return (not disconnected) if get_connection_status else compatible
		
func get_tile_types_compatible_with_tile_type_in_relative_direction(tile_type: TileType, relative_position: Enums.RelativePosition) -> Array[TileType]:
	var tile_types_compatible: Array[TileType] = []

	for checking_tile_type_id_pair: Vector2i in tile_type_lookup_table.keys():
		var checking_tile_type: TileType = tile_type_lookup_table[checking_tile_type_id_pair]
		
		var compatible: bool = check_if_tile_types_compatible_or_connected(
			tile_type,
			checking_tile_type, 
			relative_position,
			false
		)

		if not compatible:
			continue

		tile_types_compatible.append(checking_tile_type)
	
	return tile_types_compatible

func calculate_tile_entropy(location: Vector2i) -> TileEntropy:
	var neighbouring_tile_instances: Dictionary[Enums.RelativePosition, TileInstance] = get_tile_instances_neighbouring_location(location)

	var valid_tile_types: Array[TileType] = tile_type_lookup_table.values() 

	for relative_position: Enums.RelativePosition in neighbouring_tile_instances:
		var neighbouring_tile_instance: TileInstance = neighbouring_tile_instances[relative_position]

		if not neighbouring_tile_instance:
			continue

		var valid_tile_types_for_relative_position: Array[TileType] = get_tile_types_compatible_with_tile_type_in_relative_direction(
			neighbouring_tile_instance.tile_type,
			RELATIVE_POSITION_TO_OPPOSITE_RELATIVE_POSITION[relative_position]
		)

		var new_valid_tile_types: Array[TileType] = []

		for valid_tile_type: TileType in valid_tile_types:
			if valid_tile_type not in valid_tile_types_for_relative_position:
				continue

			new_valid_tile_types.append(valid_tile_type)

		valid_tile_types = new_valid_tile_types

	return TileEntropy.new(
		location,
		valid_tile_types
	)

func trigger_entropy_calculation(location: Vector2i) -> void:
	# print("currently in %s" % location)

	var default_tile_entropy: TileEntropy = TileEntropy.new(
		location,
		default_valid_tile_types
	)

	var original_tile_entropy: TileEntropy = tile_entropy_lookup_table.get(
		location,
		default_tile_entropy
	)

	# print(default_tile_entropy.location)
	# print(default_tile_entropy.valid_tile_types)

	# print(original_tile_entropy.location)
	# print(original_tile_entropy.valid_tile_types)

	var new_tile_entropy: TileEntropy = calculate_tile_entropy(location)

	tile_entropy_lookup_table[location] = new_tile_entropy

	if not original_tile_entropy:
		return

	if new_tile_entropy.is_equal(original_tile_entropy):
		return

	# print("entropy changed")

	for location_offset: Vector2i in RELATIVE_POSITION_TO_LOCATION_OFFSET.values():
		trigger_entropy_calculation(location + location_offset)



func placeSegment(segment_type: Enums.TrackSegmentType, segment: int, segment_position: Vector2i) -> void:
	self.set_cell(segment_position, segment_type, Vector2i(0, 0), segment)



func _init() -> void:
	load_tile_type_lookup_table()

	initialise_default_valid_tile_types()

	# await get_tree().create_timer(5).timeout

	# print("a")
	# print(entropyLookupTable.get(Vector2i(0, -1)))
	# print(entropyLookupTable)
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

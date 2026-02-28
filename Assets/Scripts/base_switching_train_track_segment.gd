extends BaseTrainTrackSegment
class_name BaseSwitchingTrainTrackSegment

@export var currentSwitchState: int
@export var trainTrackSegments: Array[BaseTrainTrackSegment]

var currentTrainTrackSegment: BaseTrainTrackSegment

func enableSegment(train_track_segment: BaseTrainTrackSegment):
	currentTrainTrackSegment = train_track_segment

	currentTrainTrackSegment.showSegment()

	directionMap = currentTrainTrackSegment.directionMap
	# exitDirectionToNextTrainTrackSegmentMap = currentTrainTrackSegment.exitDirectionToNextTrainTrackSegmentMap
	entryDirectionToTrainTrackPieceMap = currentTrainTrackSegment.entryDirectionToTrainTrackPieceMap
	trainTrackPieces = currentTrainTrackSegment.trainTrackPieces

func _ready() -> void:
	super()

	for train_track_segment in trainTrackSegments:
		train_track_segment.hideSegment()

	enableSegment(trainTrackSegments[currentSwitchState])

func toggleSwitchTrack():
	trainTrackSegments[currentSwitchState].hideSegment()

	currentSwitchState += 1

	if currentSwitchState == len(trainTrackSegments):
		currentSwitchState = 0

	enableSegment(trainTrackSegments[currentSwitchState])

func _on_toggle_selection_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is not InputEventMouseButton:
		return

	if event.button_index != MOUSE_BUTTON_LEFT or not event.pressed:
		return

	var original_direction_map = directionMap

	toggleSwitchTrack()

	var new_direction_map = directionMap

	for train in trainsInTrack:
		if original_direction_map.get(train.currentDirection) != new_direction_map.get(train.currentDirection):
			print("Derailment!")

extends Node2D
class_name TrainMovementHandler

@export var train: Train

const ACCELERATION_CONSTANT: float = 96.0
const DECELERATION_CONSTANT: float = -384.0

var currentAcceleration: float = 0.0
var currentSpeed: float = 0.0

func _ready() -> void:
	train.currentTrainTrackSegment.trainsInTrack.append(train)

	if train.currentTrainTrackSegment is BaseStationTrainTrackSegment:
		train.currentTrainTrackSegment.inheritPropertiesOfTrainTrackSegment()

	print(train.currentTrainTrackSegment.entryDirectionToTrainTrackPieceMap)
	print(train.currentDirection)

	train.currentTrainTrackPiece = train.currentTrainTrackSegment.entryDirectionToTrainTrackPieceMap.get(train.currentDirection)

	train.currentTrainTrackPiece.connectTrain(train)

	train.currentDirection = train.currentTrainTrackSegment.directionMap.get(train.currentDirection)

	currentAcceleration = ACCELERATION_CONSTANT

func updateSpeed(delta: float):
	currentSpeed += currentAcceleration * delta

	if currentSpeed > train.maxSpeed:
		currentAcceleration = 0

		currentSpeed = train.maxSpeed

	if currentSpeed < 0.0:
		currentAcceleration = 0

		currentSpeed = 0.0

func updatePosition(delta: float) -> bool:
	if delta > 0.1:
		delta = 0.1

	var pixels_left_to_cover = currentSpeed * delta

	var length_of_first_track_piece = train.currentTrainTrackPiece.getTotalLength()
	var remaining_length_of_first_track_piece = length_of_first_track_piece - train.currentTrainTrackPiece.pathFollow2D.progress

	if remaining_length_of_first_track_piece > pixels_left_to_cover:
		moveByProgressPxOfPathFollow2D(pixels_left_to_cover)

	else:
		moveByProgressPxOfPathFollow2D(remaining_length_of_first_track_piece)

		pixels_left_to_cover -= remaining_length_of_first_track_piece

		var successful = changeToNextTrainTrackSegment()

		if not successful:
			return false

		moveByProgressPxOfPathFollow2D(pixels_left_to_cover)

	return true

func moveByProgressPxOfPathFollow2D(progress_px: float):
	var path_follow_2d = train.currentTrainTrackPiece.pathFollow2D

	path_follow_2d.progress += progress_px

func _process(delta: float) -> void:
	updateSpeed(delta)

	updatePosition(delta)

func changeToNextTrainTrackSegment() -> bool:
	train.currentTrainTrackPiece.disconnectTrain()

	train.currentTrainTrackPiece.pathFollow2D.progress = 0.0

	train.currentTrainTrackSegment.trainsInTrack.erase(train)

	var nextTrainTrackSegment = train.currentTrainTrackSegment.exitDirectionToNextTrainTrackSegmentMap.get(train.currentDirection)
	if not nextTrainTrackSegment:
		return false

	train.currentTrainTrackSegment = nextTrainTrackSegment

	train.currentTrainTrackPiece = train.currentTrainTrackSegment.entryDirectionToTrainTrackPieceMap.get(train.currentDirection)

	if not train.currentTrainTrackPiece:
		print(train.currentTrainTrackSegment.name)
		print(train.currentTrainTrackSegment.entryDirectionToTrainTrackPieceMap)

	train.currentTrainTrackSegment.trainsInTrack.append(train)

	train.currentTrainTrackPiece.connectTrain(train)

	train.currentDirection = train.currentTrainTrackSegment.directionMap.get(train.currentDirection)

	return true

func reverseTrain():
	var path_follow_2d = train.currentTrainTrackPiece.pathFollow2D

	path_follow_2d.progress_ratio = (1 - path_follow_2d.progress_ratio)

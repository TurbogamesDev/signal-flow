extends Node2D
class_name Train

@export var currentTrainTrackSegment: BaseTrainTrackSegment
@export var currentDirection: Enums.TrainDirection

var currentTrainTrackPiece: TrainTrackPiece

var currentTween: Tween

var lastSignalSensor: SignalSensor

@export var maxSpeed: float

const ACCELERATION_CONSTANT_PX_S2: float = 96.0
const DECELERATION_CONSTANT_PX_S2: float = -384.0

var currentAcceleration_Px_S2: float = 0.0
var currentSpeed_Px_S: float = 0.0

func _ready() -> void:
	currentTrainTrackSegment.trainsInTrack.append(self)

	currentTrainTrackPiece = currentTrainTrackSegment.entryDirectionToTrainTrackPieceMap.get(currentDirection)
	currentTrainTrackPiece.connectTrain(self)

	currentDirection = currentTrainTrackSegment.directionMap.get(currentDirection)

	currentAcceleration_Px_S2 = ACCELERATION_CONSTANT_PX_S2


func updateSpeed(delta: float):
	currentSpeed_Px_S += currentAcceleration_Px_S2 * delta

	if currentSpeed_Px_S > maxSpeed:
		currentAcceleration_Px_S2 = 0

		currentSpeed_Px_S = maxSpeed

	if currentSpeed_Px_S < 0.0:
		currentAcceleration_Px_S2 = 0

		currentSpeed_Px_S = 0.0

func updatePosition(delta: float) -> bool:
	if delta > 0.1:
		delta = 0.1
	
	print(delta)
	print(currentSpeed_Px_S)

	var pixels_left_to_cover = currentSpeed_Px_S * delta

	var length_of_first_track_piece = currentTrainTrackPiece.getTotalLength()
	var remaining_length_of_first_track_piece = length_of_first_track_piece - currentTrainTrackPiece.pathFollow2D.progress

	if remaining_length_of_first_track_piece > pixels_left_to_cover:
		moveByProgressPxOfPathFollow2D(pixels_left_to_cover)

		print("moving by %f" % pixels_left_to_cover)

	else:
		moveByProgressPxOfPathFollow2D(remaining_length_of_first_track_piece)

		pixels_left_to_cover -= remaining_length_of_first_track_piece

		var successful = changeToNextTrainTrackSegment()

		if not successful:
			return false

		moveByProgressPxOfPathFollow2D(pixels_left_to_cover)

	return true

		

func moveByProgressPxOfPathFollow2D(progress_px: float):
	var path_follow_2d = currentTrainTrackPiece.pathFollow2D

	path_follow_2d.progress += progress_px

func _process(delta: float) -> void:
	updateSpeed(delta)

	updatePosition(delta)
	

func changeToNextTrainTrackSegment() -> bool:
	currentTrainTrackPiece.disconnectTrain()

	currentTrainTrackPiece.pathFollow2D.progress = 0.0

	currentTrainTrackSegment.trainsInTrack.erase(self)

	var nextTrainTrackSegment = currentTrainTrackSegment.exitDirectionToNextTrainTrackSegmentMap.get(currentDirection)
	if not nextTrainTrackSegment:
		return false

	currentTrainTrackSegment = nextTrainTrackSegment

	currentTrainTrackPiece = currentTrainTrackSegment.entryDirectionToTrainTrackPieceMap.get(currentDirection)

	currentTrainTrackSegment.trainsInTrack.append(self)

	currentTrainTrackPiece.connectTrain(self)

	currentDirection = currentTrainTrackSegment.directionMap.get(currentDirection)

	return true

func handleSignalSensor(signalSensor: SignalSensor) -> void:
	if signalSensor == lastSignalSensor:
		return

	var train_track_piece: TrainTrackPiece = signalSensor.trainTrackPiece

	if train_track_piece != currentTrainTrackPiece:
		return
	
	lastSignalSensor = signalSensor

	var train_signal: TrainSignal = train_track_piece.trainSignal

	if train_signal.direction != currentDirection:
		return

	if train_signal.proceed:
		return

	currentAcceleration_Px_S2 = DECELERATION_CONSTANT_PX_S2

	await train_signal.changed

	currentAcceleration_Px_S2 = ACCELERATION_CONSTANT_PX_S2

func _on_collision_detector_area_entered(area: Area2D) -> void:
	print("area2d detected")
	print(area)

	if area is not SignalSensor:
		return

	handleSignalSensor(area)
	

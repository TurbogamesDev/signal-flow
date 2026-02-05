extends Node2D
class_name Train

@export var currentTrainTrackSegment: BaseTrainTrackSegment
@export var currentDirection: Enums.TrainDirection

var currentTrainTrackPiece: TrainTrackPiece

var currentColourTween

var lastSignalSensor: SignalSensor

@export var maxSpeed: float
@export var polygon2D: Polygon2D

const MOVING_COLOR: Color = Color(1, 1, 1, 1)
const PLATFORM_COLOR: Color = Color(0.75, 0.75, 0.75, 1)

const PLATFORM_WAIT_TIME: float = 15.0

const ACCELERATION_CONSTANT: float = 96.0
const DECELERATION_CONSTANT: float = -384.0

var currentAcceleration: float = 0.0
var currentSpeed: float = 0.0

func _ready() -> void:
	currentTrainTrackSegment.trainsInTrack.append(self)

	currentTrainTrackPiece = currentTrainTrackSegment.entryDirectionToTrainTrackPieceMap.get(currentDirection)
	currentTrainTrackPiece.connectTrain(self)

	currentDirection = currentTrainTrackSegment.directionMap.get(currentDirection)

	currentAcceleration = ACCELERATION_CONSTANT


func updateSpeed(delta: float):
	currentSpeed += currentAcceleration * delta

	if currentSpeed > maxSpeed:
		currentAcceleration = 0

		currentSpeed = maxSpeed

	if currentSpeed < 0.0:
		currentAcceleration = 0

		currentSpeed = 0.0

func updatePosition(delta: float) -> bool:
	if delta > 0.1:
		delta = 0.1
	
	# print(delta)
	# print(currentSpeed)

	var pixels_left_to_cover = currentSpeed * delta

	var length_of_first_track_piece = currentTrainTrackPiece.getTotalLength()
	var remaining_length_of_first_track_piece = length_of_first_track_piece - currentTrainTrackPiece.pathFollow2D.progress

	if remaining_length_of_first_track_piece > pixels_left_to_cover:
		moveByProgressPxOfPathFollow2D(pixels_left_to_cover)

		# print("moving by %f" % pixels_left_to_cover)

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

func handleTrainSignalDetection(train_signal: TrainSignal):
	if train_signal.direction != currentDirection:
		return

	if train_signal.proceed:
		return

	currentAcceleration = DECELERATION_CONSTANT

	await train_signal.changed

	currentAcceleration = ACCELERATION_CONSTANT


func handleSignalSensorDetection(signal_sensor: SignalSensor) -> void:
	if signal_sensor == lastSignalSensor:
		return

	var train_track_piece: TrainTrackPiece = signal_sensor.trainTrackPiece

	if train_track_piece != currentTrainTrackPiece:
		return
	
	lastSignalSensor = signal_sensor

	var train_signal: TrainSignal = train_track_piece.trainSignal

	handleTrainSignalDetection(train_signal)

func handleThroughPlatformSensorDetection():
	currentAcceleration = DECELERATION_CONSTANT
	
	polygon2D.color = PLATFORM_COLOR

	await get_tree().create_timer(PLATFORM_WAIT_TIME).timeout

	# currentColourTween = get_tree().create_tween() \
	# 	.tween_property(polygon2D, "color", MOVING_COLOR, 15.0)

	# await currentColourTween.finished

	polygon2D.color = MOVING_COLOR

	currentAcceleration = ACCELERATION_CONSTANT

func handlePlatformSensorDetection(platform_sensor: PlatformSensor):
	if platform_sensor.terminatingPlatform:
		pass
	else:
		handleThroughPlatformSensorDetection()

func _on_collision_detector_area_entered(area: Area2D) -> void:
	if area is SignalSensor:
		handleSignalSensorDetection(area)
	elif area is PlatformSensor:
		handlePlatformSensorDetection(area)

	

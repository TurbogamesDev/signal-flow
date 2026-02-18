extends Node2D
class_name TrainSensorHandler

@export var train: Train

var lastSignalSensor: SignalSensor
var lastPlatformSensor: PlatformSensor

var justTerminated: bool = false

const MOVING_COLOR: Color = Color(1, 1, 1, 1)
const PLATFORM_COLOR: Color = Color(0.75, 0.75, 0.75, 1)

const PLATFORM_WAIT_TIME: float = 3.0

signal danger_signal_detected
signal signal_cleared

signal station_detected
signal halt_completed

signal terminal_reached

func handleTrainSignalDetection(train_signal: TrainSignal):	
	print("Is train signal a terminating one?: %s" % ("Yes" if train_signal.terminating else "No"))

	if train_signal.direction != train.currentDirection:
		return

	if train_signal.terminating:
		if not justTerminated:
			return

		justTerminated = false

	if train_signal.proceed:
		return

	danger_signal_detected.emit()

	# train.currentAcceleration = train.trainMovementHandler.DECELERATION_CONSTANT

	await train_signal.changed

	signal_cleared.emit()

	# currentAcceleration = ACCELERATION_CONSTANT


func handleSignalSensorDetection(signal_sensor: SignalSensor) -> void:
	if signal_sensor == lastSignalSensor:
		return

	var train_track_piece: TrainTrackPiece = signal_sensor.trainTrackPiece

	if train_track_piece != train.currentTrainTrackPiece:
		return
	
	lastSignalSensor = signal_sensor

	var train_signal: TrainSignal = train_track_piece.trainSignal

	handleTrainSignalDetection(train_signal)

func handleThroughPlatformSensorDetection():
	station_detected.emit()
	
	train.polygon2D.color = PLATFORM_COLOR

	await get_tree().create_timer(PLATFORM_WAIT_TIME).timeout

	train.polygon2D.color = MOVING_COLOR

	halt_completed.emit()

func handleTerminatingPlatformSensorDetection():
	station_detected.emit()
	
	train.polygon2D.color = PLATFORM_COLOR

	await get_tree().create_timer(PLATFORM_WAIT_TIME).timeout

	terminal_reached.emit()

	train.polygon2D.color = MOVING_COLOR

	halt_completed.emit()

	justTerminated = true

func handlePlatformSensorDetection(platform_sensor: PlatformSensor):
	if platform_sensor == lastPlatformSensor:
		return

	lastPlatformSensor = platform_sensor

	if platform_sensor.terminatingPlatform:
		handleTerminatingPlatformSensorDetection()
	else:
		handleThroughPlatformSensorDetection()

func _on_collision_detector_area_entered(area: Area2D) -> void:
	if area is SignalSensor:
		handleSignalSensorDetection(area)
	elif area is PlatformSensor:
		handlePlatformSensorDetection(area)

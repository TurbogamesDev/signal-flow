extends Node2D
class_name Train

@export var maxSpeed: float
@export var polygon2D: Polygon2D

@export var trainMovementHandler: TrainMovementHandler
@export var trainSensorHandler: TrainSensorHandler

@export var currentTrainTrackSegment: BaseTrainTrackSegment
@export var currentDirection: Enums.TrainDirection

var currentTrainTrackPiece: TrainTrackPiece

func _on_collision_detector_area_entered(area: Area2D) -> void:
	if area is SignalSensor:
		trainSensorHandler.handleSignalSensorDetection(area)
	elif area is PlatformSensor:
		trainSensorHandler.handlePlatformSensorDetection(area)

func _on_danger_signal_detected():
	trainMovementHandler.currentAcceleration = trainMovementHandler.DECELERATION_CONSTANT

func _on_signal_cleared():
	trainMovementHandler.currentAcceleration = trainMovementHandler.ACCELERATION_CONSTANT

func _on_station_detected():
	trainMovementHandler.currentAcceleration = trainMovementHandler.DECELERATION_CONSTANT

func _on_halt_completed():
	trainMovementHandler.currentAcceleration = trainMovementHandler.ACCELERATION_CONSTANT

func _on_terminal_reached():
	trainMovementHandler.reverseTrain()

func _ready() -> void:
	trainSensorHandler.connect("danger_signal_detected", _on_danger_signal_detected)
	trainSensorHandler.connect("signal_cleared", _on_signal_cleared)
	trainSensorHandler.connect("station_detected", _on_station_detected)
	trainSensorHandler.connect("halt_completed", _on_halt_completed)
	trainSensorHandler.connect("terminal_reached", _on_terminal_reached)
	
	
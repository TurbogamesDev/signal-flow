extends Node2D
class_name Train

@export var currentTrainTrackSegment: BaseTrainTrackSegment
@export var currentDirection: Enums.TrainDirection

var currentTrainTrackPiece: TrainTrackPiece

var currentTween: Tween

var lastSignalSensor: SignalSensor

const SPEED_PIXELS_PER_SECOND = 64

func _ready() -> void:
	currentTrainTrackSegment.trainsInTrack.append(self)

	currentTrainTrackPiece = currentTrainTrackSegment.entryDirectionToTrainTrackPieceMap.get(currentDirection)

	while true:
		await followCurrentTrainTrackPiece()
		
		var successful = changeToNextTrainTrackSegment()

		# print(successful)

		if not successful:
			break

func followCurrentTrainTrackPiece():
	print("following train track %s of %s" % [currentTrainTrackPiece.name, currentTrainTrackSegment.name])

	currentTrainTrackPiece.connectTrain(self)

	var length_of_track_piece = currentTrainTrackPiece.getTotalLength()
	
	currentTween = get_tree().create_tween()
	currentTween.tween_property(currentTrainTrackPiece.pathFollow2D, "progress_ratio", 1.0, length_of_track_piece / SPEED_PIXELS_PER_SECOND)

	await currentTween.finished

	currentTrainTrackPiece.disconnectTrain()

	currentTrainTrackPiece.pathFollow2D.progress_ratio = 0

func changeToNextTrainTrackSegment() -> bool:
	print("changing train track")

	currentDirection = currentTrainTrackSegment.directionMap.get(currentDirection)

	currentTrainTrackSegment.trainsInTrack.erase(self)

	var nextTrainTrackSegment = currentTrainTrackSegment.exitDirectionToNextTrainTrackSegmentMap.get(currentDirection)
	if not nextTrainTrackSegment:
		return false

	currentTrainTrackSegment = nextTrainTrackSegment

	currentTrainTrackPiece = currentTrainTrackSegment.entryDirectionToTrainTrackPieceMap.get(currentDirection)

	currentTrainTrackSegment.trainsInTrack.append(self)

	return true

func _on_collision_detector_area_entered(area: Area2D) -> void:
	print("area2d detected")
	print(area)

	if area is not SignalSensor:
		return

	if area == lastSignalSensor:
		return

	var train_track_piece: TrainTrackPiece = area.trainTrackPiece

	if train_track_piece != currentTrainTrackPiece:
		return
	
	lastSignalSensor = area

	var train_signal: TrainSignal = train_track_piece.trainSignal

	print(train_signal.proceed)

	if train_signal.proceed:
		return

	if currentTween:
		currentTween.pause()

	await train_signal.changed

	if currentTween:
		currentTween.play()

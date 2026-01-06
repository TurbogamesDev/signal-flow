extends Area2D
class_name Train_OLD

@export var currentTrainTrack: TrainTrackPiece_OLD
var currentTween: Tween

func _ready() -> void:
	while true:
		await followCurrentTrainTrack()

		if not currentTrainTrack.nextTrainTrack:
			break
		
		var train_signal = currentTrainTrack.trainSignal

		if train_signal:
			var can_proceed = train_signal.proceed

			if not can_proceed:
				await train_signal.changed

		changeToNextTrainTrack()
	

func followCurrentTrainTrack():
	print("following train track")
	print(currentTrainTrack.name)

	currentTrainTrack.connectTrain(self)

	currentTween = get_tree().create_tween()
	currentTween.tween_property(currentTrainTrack.pathFollow2D, "progress_ratio", 1.0, 3)

	await currentTween.finished

	currentTrainTrack.pathFollow2D.progress_ratio = 0

	currentTrainTrack.disconnectTrain()

func changeToNextTrainTrack():
	print("changing train track")

	var nextTrainTrack = currentTrainTrack.nextTrainTrack

	currentTrainTrack = nextTrainTrack

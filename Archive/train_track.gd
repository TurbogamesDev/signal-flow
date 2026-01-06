extends Line2D
class_name TrainTrackPiece_OLD

@export var nextTrainTrack: TrainTrackPiece
@export var pathFollow2D: PathFollow2D
@export var remoteTransform2D: RemoteTransform2D
@export var path2D: Path2D
@export var trainSignal: TrainSignal

func _ready() -> void:
	print(path2D)

	path2D.curve.clear_points()

	for point in self.points:
		path2D.curve.add_point(point, Vector2(0, 0), Vector2(0, 0))

	print(path2D.curve.point_count)

func connectTrain(train: Train):
	remoteTransform2D.remote_path = train.get_path()

	remoteTransform2D.force_update_cache()

func disconnectTrain():
	remoteTransform2D.remote_path = ""

	remoteTransform2D.force_update_cache()


		
	

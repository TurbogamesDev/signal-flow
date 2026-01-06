extends Line2D
class_name TrainTrackPiece

@export var pathFollow2D: PathFollow2D
@export var remoteTransform2D: RemoteTransform2D
@export var path2D: Path2D
@export var trainSignal: TrainSignal
# @export var trainSignalProgressRatioLocation: float

func _ready() -> void:
	gradient = null

	path2D.curve.clear_points()

	for point in self.points:
		path2D.curve.add_point(point, Vector2(0, 0), Vector2(0, 0))

func getTotalLength() -> float:
	var total_length: float = 0.0

	if points.size() < 2:
		return 0.0

	for i in range(points.size() - 1):
		var current_point: Vector2 = points[i]
		var next_point: Vector2 = points[i + 1]
		
		total_length += current_point.distance_to(next_point)

	return total_length


func connectTrain(train: Train):
	remoteTransform2D.remote_path = train.get_path()

	remoteTransform2D.force_update_cache()

func disconnectTrain():
	remoteTransform2D.remote_path = ""

	remoteTransform2D.force_update_cache()


		
	

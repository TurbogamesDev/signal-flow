extends BaseTrainTrackSegment
class_name BaseStationTrainTrackSegment

@export var entryTrainTrackSegment: BaseTrainTrackSegment

func inheritPropertiesOfTrainTrackSegment():
	directionMap = entryTrainTrackSegment.directionMap
	entryDirectionToTrainTrackPieceMap = entryTrainTrackSegment.entryDirectionToTrainTrackPieceMap
	trainTrackPieces = entryTrainTrackSegment.trainTrackPieces

func _ready() -> void:
	super()

	inheritPropertiesOfTrainTrackSegment()

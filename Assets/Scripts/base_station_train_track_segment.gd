extends BaseTrainTrackSegment
class_name BaseStationTrainTrackSegment

@export var trainTrackSegment: BaseTrainTrackSegment

func inheritPropertiesOfTrainTrackSegment(train_track_segment: BaseTrainTrackSegment):
    directionMap = train_track_segment.directionMap
    entryDirectionToTrainTrackPieceMap = train_track_segment.entryDirectionToTrainTrackPieceMap
    trainTrackPieces = train_track_segment.trainTrackPieces

func _ready() -> void:
    inheritPropertiesOfTrainTrackSegment(trainTrackSegment)
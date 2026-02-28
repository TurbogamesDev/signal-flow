extends Node2D
class_name BaseTrainTrackSegment

@export var directionMap: Dictionary[Enums.TrainDirection, Enums.TrainDirection]
@export var exitDirectionToNextTrainTrackSegmentMap: Dictionary[Enums.TrainDirection, BaseTrainTrackSegment]
@export var entryDirectionToTrainTrackPieceMap: Dictionary[Enums.TrainDirection, TrainTrackPiece]

@export var trainTrackPieces: Array[TrainTrackPiece]

var trainsInTrack: Array[Train]

const HIDDEN_Z_INDEX = -10
const SHOWN_Z_INDEX = 0

const SHOWN_COLOR: Color = Color(1, 1, 1) 
const HIDDEN_COLOR: Color = Color(0.5, 0.5, 0.5)

func _ready() -> void:
    var track_segment_grid = get_parent()

    if track_segment_grid is TrackSegmentGrid:
        track_segment_grid.registerSegment(
            track_segment_grid.local_to_map(position),
            self
        )
        



func hideSegment():
    for train_track_piece in trainTrackPieces:
        train_track_piece.default_color = HIDDEN_COLOR

        train_track_piece.z_index = HIDDEN_Z_INDEX

func showSegment():
    for train_track_piece in trainTrackPieces:
        train_track_piece.default_color = SHOWN_COLOR

        train_track_piece.z_index = SHOWN_Z_INDEX


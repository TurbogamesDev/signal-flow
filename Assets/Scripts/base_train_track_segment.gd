extends Node2D
class_name BaseTrainTrackSegment

@export var directionMap: Dictionary[Enums.TrainDirection, Enums.TrainDirection]
@export var exitDirectionToNextTrainTrackSegmentMap: Dictionary[Enums.TrainDirection, BaseTrainTrackSegment]
@export var entryDirectionToTrainTrackPieceMap: Dictionary[Enums.TrainDirection, TrainTrackPiece]

@export var trainTrackPieces: Array[TrainTrackPiece]

@export var trainsInTrack: Array[Train]

const HIDDEN_Z_INDEX = -10
const SHOWN_Z_INDEX = 0

const HIDDEN_ALPHA_VALUE = 0.5

func hideSegment():
    for train_track_piece in trainTrackPieces:
        train_track_piece.default_color.a = HIDDEN_ALPHA_VALUE

        train_track_piece.z_index = HIDDEN_Z_INDEX

func showSegment():
    for train_track_piece in trainTrackPieces:
        train_track_piece.default_color.a = 1

        train_track_piece.z_index = SHOWN_Z_INDEX


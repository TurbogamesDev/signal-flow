extends Area2D

var switched: bool = false
@export var mainTrack: TrainTrack
@export var branchTrack: TrainTrack

func switchTrack():
	switched = not switched

	if switched:
		branchTrack.default_color = Color(1, 1, 1, 1)
		mainTrack.default_color = Color(0.5, 0.5, 0.5, 1)

		branchTrack.z_index = 1
		mainTrack.z_index = -5

	else:
		branchTrack.default_color = Color(0.5, 0.5, 0.5, 1)
		mainTrack.default_color = Color(1, 1, 1, 1)

		branchTrack.z_index = -5
		mainTrack.z_index = 1


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is not InputEventMouseButton:
		return

	if event.button_index != MOUSE_BUTTON_LEFT or not event.pressed:
		return

	switchTrack()

	


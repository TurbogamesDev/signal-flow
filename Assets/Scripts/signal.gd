extends Area2D
class_name TrainSignal

@export var polygon2D: Polygon2D
var proceed = false

signal changed(proceed: bool)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is not InputEventMouseButton:
		return

	if event.button_index != MOUSE_BUTTON_LEFT or not event.pressed:
		return

	toggleSignal()

func toggleSignal():
	proceed = not proceed

	changed.emit(proceed)

	if proceed:
		polygon2D.color = Color(0, 1, 0, 1)
	else:
		polygon2D.color = Color(1, 0, 0, 1)



extends Area2D
class_name TrainSignal

@export var polygon2D: Polygon2D
@export var direction: Enums.TrainDirection
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

func _on_area_entered(area: Area2D) -> void:
	if area is not TrainSignal:
		return
	assert(area is TrainSignal)

	if self.get_instance_id() > area.get_instance_id():
		return

	self.set_deferred("monitorable", false)
	self.set_deferred("monitoring", false)
	self.set_deferred("input_pickable", false)

	self.monitorable = false
	self.monitoring = false
	self.input_pickable = false

	self.hide()

	var on_other_signal_aspect_change = func(other_signal_proceed: bool):
		print("new signal: %s" % str(other_signal_proceed))

		proceed = other_signal_proceed

		changed.emit(proceed)

	area.changed.connect(on_other_signal_aspect_change)



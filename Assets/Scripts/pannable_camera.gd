extends Camera2D
class_name PannableCamera

var isPanning: bool = false
@export var zoomFactor: float

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action("camera_pan"):
        isPanning = event.is_pressed()

    if event is InputEventMouseMotion and isPanning:
        global_position -= event.relative * (1.0 / zoom.x)

    if event.is_action("zoom_in"):
        zoom *= zoomFactor

    if event.is_action("zoom_out"):
        zoom /= zoomFactor
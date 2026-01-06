extends Path2D

@export var pathFollow2D: PathFollow2D

func _physics_process(_delta: float) -> void:
    pathFollow2D.progress_ratio += 0.01


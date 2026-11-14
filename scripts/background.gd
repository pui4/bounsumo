extends Sprite2D

@export var camera := Camera2D

func _process(delta: float) -> void:
	global_position = camera.global_position * 0.7

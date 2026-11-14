extends Sprite2D

func _process(delta: float) -> void:
	global_position = $"../Camera2D".global_position*0.7

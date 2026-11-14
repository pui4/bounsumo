extends Node2D

func _ready() -> void:
	if Lib.main_scene == null:
		Lib.main_scene = self

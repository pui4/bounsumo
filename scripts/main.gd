extends Control

@onready var sub_view := $"SubViewportContainer/SubViewport"

func _ready() -> void:
	Lib.parent = sub_view
	sub_view.get_viewport().set_size(get_window().size)
	get_window().size_changed.connect(_on_size_change)

func _on_size_change() -> void:
	sub_view.get_viewport().set_size(get_window().size)

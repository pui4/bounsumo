extends Area2D

@onready var line := $"Line2D"

var target_body : CharacterBody2D

func _physics_process(delta: float) -> void:
	if target_body != null:
		line.set_point_position(1, target_body.global_position)
		print(line.points[1])

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		target_body = body

extends Area2D

@export var right : bool
@export var strength := 75
@export var elasticity := 10
@export var out_range := 250
@export var in_range := 35

@onready var line := $"Line2D"

var target_body : CharacterBody2D

func _physics_process(delta: float) -> void:
	if target_body != null:
		line.set_point_position(1, target_body.global_position - line.global_position)
		target_body.velocity.x += (global_position.x - target_body.global_position.x) * strength * delta
		target_body.velocity.y /= 2
		
		var distance = target_body.global_position.x - global_position.x
		if right:
			distance *= -1
		
		if distance <= -out_range or distance >= in_range:
			target_body = null
	else:
		line.set_point_position(1, lerp(line.points[1], Vector2.ZERO, elasticity * delta))

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		target_body = body

extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		if body.is_player2:
			pass

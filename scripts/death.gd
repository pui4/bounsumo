extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		if body.is_player2:
			Lib.p1_score += 1
		else:
			Lib.p2_score += 1
		Lib.death.emit()
		Lib.reload()

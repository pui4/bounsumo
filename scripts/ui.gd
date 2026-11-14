extends Control

@onready var p1_text = $"p1Health"
@onready var p2_text = $"p2Health"
@onready var score_text = $"score"

func _ready() -> void:
	Lib.health_change.connect(_on_heath_change)
	Lib.death.connect(_on_death)

func _on_heath_change(player2: bool, new_val: int) -> void:
	if player2:
		p2_text.text = "[wave][center]" + str(new_val) + "%"
	else:
		p1_text.text = "[wave][center]" + str(new_val) + "%"

func _on_death():
	score_text.text = str(Lib.p1_score) + ":" + str(Lib.p2_score)

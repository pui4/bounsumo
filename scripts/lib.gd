extends Node

var player1 : CharacterBody2D
var player2 : CharacterBody2D

var p1_score := 0
var p2_score := 0

var main_scene : Node2D
var parent : SubViewport

@onready var main := preload("res://debug.tscn")

signal health_change
signal death

func reload():
	main_scene.queue_free()
	var main_inst = main.instantiate()
	parent.add_child(main_inst)
	main_scene = main_inst
	
	health_change.emit(0, 0)
	health_change.emit(1, 0)

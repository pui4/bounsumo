extends CharacterBody2D

@export var additional_rotation = 0.0

@export var is_player2 : bool

@export var move_speed := 2000
@export var friction := 1.1
@export var air_friction := 1.01
@export var gravity := 1000
@export var base_knockback := 50
@export var base_knockback_up := 15
@export var parry_knockback := 750

@export var boost := 500

@onready var parry_timer := $"ParryTime"
@onready var cooldown_timer := $"ParryCooldown"
@onready var anim_timer := $"AnimReset"
@onready var hold_timer := $"HoldTime"
@onready var sprite1 := $Node2D/Sprite2D
@onready var sprite2 := $Node2D/Sprite2D2
@onready var player := $AnimationPlayer

var sprite : AnimatedSprite2D

var damage := 0

var input_addon : String
var direction := -1
var done_boost
var target_player : CharacterBody2D

var can_move := true
var can_attack := false



func _ready() -> void:
	if is_player2:
		Lib.player2 = self
		input_addon = "p2_"
		direction = 1
		sprite1.hide()
		sprite2.show()
		sprite = sprite2
	else:
		sprite = sprite1
		Lib.player1 = self

func _process(delta: float) -> void:
	rotation = additional_rotation * direction

func _physics_process(delta: float) -> void:
	var axis := Input.get_axis(input_addon + "left", input_addon + "right")
	
	if cooldown_timer.time_left <= 0 and parry_timer.time_left <= 0 and can_move:
		velocity.x += axis * move_speed * delta
		
		if axis != 0 and sprite.frame == 0:
			sprite.frame = 1
			player.play("RESET")
			player.play("dash")
		elif axis == 0 and sprite.frame == 1:
			sprite.frame = 0
		
		if axis != 0 and not done_boost:
			velocity.x = axis * boost
			done_boost = true
		elif axis == 0 and done_boost:
			done_boost = false
	
	attacks()
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	velocity.x /= friction
	velocity.y /= air_friction
	
	move_and_slide()
	
	var target : Vector2
	if not is_player2:
		target = Lib.player2.position
	else:
		target = Lib.player1.position
	
	if target.x - position.x < 0:
		sprite.flip_h = true
		direction = 1
	else:
		sprite.flip_h = false
		direction = -1

func attacks() -> void:
	if Input.is_action_pressed(input_addon + "attack") and can_move:
		velocity.x += 150 * direction
		sprite.frame = 6
		can_move = false
		hold_timer.start()
		player.play("RESET")
		player.play("charge")
	#if Input.is_action_just_released(input_addon + "attack") and sprite.frame == 6 and can_attack:
	
	if Input.is_action_just_pressed(input_addon + "parry") and parry_timer.time_left <= 0 and cooldown_timer.time_left <= 0 and sprite.frame != 6:
		parry_timer.start()
		can_move = false
		player.play("RESET")
		player.play("block")
		sprite.frame = 3

func get_attacked(body: CharacterBody2D) -> void:
	if parry_timer.time_left <= 0:
		damage += 5
		Lib.health_change.emit(is_player2, damage)
		
		velocity = Vector2(base_knockback * damage * direction, -base_knockback_up * damage)
		sprite.frame = 5
		player.play("RESET")
		player.play("hit")
		anim_timer.start()
		
		$"hit stun".start()
		can_move = false
		can_attack = false
		
	else:
		parry_timer.stop()
		sprite.frame = 0
		player.play("RESET")
		body.success_parry()

func success_parry() -> void:
	velocity = Vector2(parry_knockback * direction, 0)
	sprite.frame = 2
	can_move = false
	anim_timer.start()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players") and body != self:
		target_player = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == target_player:
		target_player = null

func _on_parry_time_timeout() -> void:
	cooldown_timer.start()
	player.play("RESET")
	player.play("block rest")
	sprite.frame = 4

func _on_parry_cooldown_timeout() -> void:
	sprite.frame = 0
	can_move = true
	player.play("RESET")

func _on_anim_reset_timeout() -> void:
	sprite.frame = 0
	player.play("RESET")
	can_move = true

func _on_hold_time_timeout() -> void:
	sprite.frame = 7
	velocity.x -= 350 * direction
	if target_player != null and parry_timer.time_left <= 0:
		target_player.get_attacked(self)
	anim_timer.start(0.2)
	can_move = false
	player.play("RESET")
	player.play("kick")
	#can_attack = false


func _on_hit_stun_timeout() -> void:
	can_move = true
	can_attack = true

extends CharacterBody2D

@export var is_player2 : bool

@export var move_speed := 2000
@export var friction := 1.1
@export var air_friction := 1.01
@export var gravity := 1000
@export var base_knockback := 50
@export var base_knockback_up := 25
@export var parry_knockback := 750

@export var boost := 500

@onready var parry_timer := $"ParryTime"
@onready var cooldown_timer := $"ParryCooldown"
@onready var sprite := $"Sprite2D"

var damage := 0

var input_addon : String
var direction := -1
var done_boost
var target_player : CharacterBody2D

func _ready() -> void:
	if is_player2:
		Lib.player2 = self
		input_addon = "p2_"
		direction = 1
	else:
		Lib.player1 = self

func _physics_process(delta: float) -> void:
	var axis := Input.get_axis(input_addon + "left", input_addon + "right")
	
	if cooldown_timer.time_left <= 0 and parry_timer.time_left <= 0:
		velocity.x += axis * move_speed * delta
		
		if axis != 0 and not done_boost:
			velocity.x = axis * boost
			done_boost = true
		elif axis == 0 and done_boost:
			done_boost = false
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	velocity.x /= friction
	velocity.y /= air_friction
	
	attacks()
	
	move_and_slide()
	
	var target : Vector2
	if not is_player2:
		target = Lib.player2.position
	else:
		target = Lib.player1.position
	
	sprite.flip_h = target.x - position.x < 0

func attacks() -> void:
	if target_player != null and Input.is_action_just_pressed(input_addon + "attack"):
		target_player.get_attacked(self)
	
	if Input.is_action_just_pressed(input_addon + "parry") and parry_timer.time_left <= 0:
		parry_timer.start()
		sprite.modulate = Color.RED

func get_attacked(body: CharacterBody2D) -> void:
	if parry_timer.time_left <= 0:
		damage += 5
		
		velocity = Vector2(base_knockback * damage * direction, -base_knockback_up * damage)
	else:
		body.success_parry()

func success_parry() -> void:
	velocity = Vector2(parry_knockback * direction, 0)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		target_player = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == target_player:
		target_player = null

func _on_parry_time_timeout() -> void:
	sprite.modulate = Color.WHITE
	cooldown_timer.start()
	sprite.modulate = Color.BLUE

func _on_parry_cooldown_timeout() -> void:
	sprite.modulate = Color.WHITE

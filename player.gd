extends CharacterBody2D

@export var speed       : float = 200.0
@export var jump_force  : float = 400.0
@export var max_jumps   : int   = 2
@export var attack_cd   : float = 0.5
@export var attack_dmg  : int   = 1
@export var max_hp      : int   = 3

var gravity     = ProjectSettings.get_setting("physics/2d/default_gravity")
var jumps_left  : int   = max_jumps
var can_attack  : bool  = true
var hp          : int
var hit_count   : int   = 0  # Penghitung serangan yang diterima

@onready var sprite     : AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_box : Area2D            = $AttackBox
@onready var hearts_hi  : HBoxContainer     = get_node("/root/Cuyrun/UI/Hearts")

func _ready():
	add_to_group("player")
	hp = max_hp
	_update_hearts()
	attack_box.damage = attack_dmg
	attack_box.target_group = "enemies"
	attack_box.monitoring = false

func _physics_process(delta):
	if is_on_floor():
		jumps_left = max_jumps

	var dir = Input.get_action_strength("right") - Input.get_action_strength("left")
	velocity.x = dir * speed
	if dir != 0:
		sprite.flip_h = dir < 0

	if Input.is_action_just_pressed("up") and jumps_left > 0:
		velocity.y = -jump_force
		jumps_left -= 1
		sprite.play("jump")

	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("attack") and can_attack:
		_start_attack()

	if not can_attack:
		pass
	elif not is_on_floor():
		sprite.play("jump")
	elif abs(velocity.x) > 0:
		sprite.play("run")
	else:
		sprite.play("idle")

	move_and_slide()

func _start_attack():
	can_attack = false
	sprite.play("attack")
	attack_box.monitoring = true
	await sprite.animation_finished
	attack_box.monitoring = false
	await get_tree().create_timer(attack_cd).timeout
	can_attack = true

func take_damage(dmg: int):
	hit_count += 1
	print("Hit count: ", hit_count)
	
	# Kurangi 1 heart setiap 2 kali serangan
	if hit_count >= 2:
		hp = max(hp - 1, 0)
		hit_count = 0  # Reset penghitung
		_update_hearts()
		print("Player lost 1 heart! Remaining: ", hp)
		
		if hp <= 0:
			_die()
		else:
			sprite.play("hit")
	else:
		sprite.play("hit")

func _update_hearts():
	if hearts_hi == null:
		return
	for i in hearts_hi.get_child_count():
		hearts_hi.get_child(i).visible = (i < hp)

func _die():
	sprite.play("dead")
	set_physics_process(false)
	collision_layer = 0
	collision_mask = 0
	attack_box.monitoring = false
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scene/GameOver.tscn")

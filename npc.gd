extends CharacterBody2D

enum State { IDLE, CHASE, ATTACK, DEAD }

@export var speed       : float = 60.0
@export var melee_dist  : float = 32.0
@export var attack_dmg  : int   = 1
@export var attack_cd   : float = 1.0
@export var max_hp      : int   = 2

var state      : State  = State.IDLE
var target     : Node2D = null
var can_attack : bool   = true
var hp         : int
var gravity    = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var area   : Area2D           = $DetectionArea
@onready var ray    : RayCast2D        = $AttackRay

func _ready():
	add_to_group("enemies")
	hp = max_hp
	area.body_entered.connect(_on_area_entered)
	area.body_exited.connect(_on_area_exited)
	ray.enabled = false
	sprite.play("idle")

func _physics_process(delta):
	if state == State.DEAD:
		return
	
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	match state:
		State.IDLE:
			velocity.x = 0
			sprite.play("idle")
		State.CHASE:
			_do_chase()
		State.ATTACK:
			velocity.x = 0

	move_and_slide()

func _do_chase():
	if target == null or not is_instance_valid(target):
		state = State.IDLE
		return

	var my_pos = global_position.x
	var target_pos = target.global_position.x
	var distance = abs(target_pos - my_pos)
	var dir = sign(target_pos - my_pos)

	if distance > melee_dist and can_attack:
		velocity.x = dir * speed
		sprite.play("run")
		sprite.flip_h = (dir < 0)  # Update arah gerakan
	elif distance <= melee_dist and can_attack:
		sprite.flip_h = (target.global_position.x < global_position.x)  # Pastikan arah serangan
		state = State.ATTACK
		_start_attack()
	else:
		velocity.x = 0

func _start_attack():
	can_attack = false
	sprite.play("attack")

	# Update raycast berdasarkan posisi aktual target
	var attack_dir = sign(target.global_position.x - global_position.x)
	ray.target_position = Vector2(melee_dist * attack_dir, 0)
	ray.enabled = true
	ray.force_raycast_update()

	await sprite.animation_finished

	if ray.is_colliding():
		var hit_body = ray.get_collider()
		if hit_body != null and hit_body.is_in_group("player"):
			hit_body.take_damage(attack_dmg)  # Panggil method take_damage

	ray.enabled = false
	await get_tree().create_timer(attack_cd).timeout
	can_attack = true

	if target != null and is_instance_valid(target):
		state = State.CHASE
	else:
		state = State.IDLE

func _on_area_entered(body):
	if body.is_in_group("player") and state != State.DEAD:
		target = body
		state = State.CHASE

func _on_area_exited(body):
	if body == target:
		target = null
		state = State.IDLE

func take_damage(dmg: int):
	if state == State.DEAD:
		return
	
	hp = max(hp - dmg, 0)
	if hp <= 0:
		_die()
	else:
		sprite.play("hit")

func _die():
	state = State.DEAD
	sprite.play("dead")
	velocity = Vector2.ZERO
	set_physics_process(false)
	collision_layer = 0
	collision_mask = 0
	area.monitoring = false
	remove_from_group("enemies")
	await get_tree().create_timer(2.0).timeout
	queue_free()

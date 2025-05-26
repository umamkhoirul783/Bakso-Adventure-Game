extends Node2D

@export var target_scene_path: String = "res://scene/HouseInterior.tscn"

@onready var anim     : AnimatedSprite2D = $AnimatedSprite2D
@onready var block_cs : CollisionShape2D  = $Blocker/CollisionShape2D
@onready var trigger  : Area2D            = $Trigger

var player_in_range := false
var is_opening      := false

func _ready():
	print("Door READY — blocker disabled? ", block_cs.disabled)
	anim.play("closed")
	block_cs.disabled = false
	trigger.connect("body_entered",  Callable(self, "_on_trigger_entered"))
	trigger.connect("body_exited",   Callable(self, "_on_trigger_exited"))
	# Connect animation_finished hanya sekali di _ready
	anim.connect("animation_finished", Callable(self, "_on_open_finished"))

func _on_trigger_entered(body):
	print("Door: ENTER triggered by ", body.name)
	if body.is_in_group("player"):
		player_in_range = true
		print("Door: player_in_range = true")

func _on_trigger_exited(body):
	print("Door: EXIT triggered by ", body.name)
	if body.is_in_group("player"):
		player_in_range = false
		print("Door: player_in_range = false")

func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact") and not is_opening:
		print("Door: GOING TO OPEN")
		_start_door_opening()

func _start_door_opening():
	is_opening = true
	block_cs.disabled = true
	trigger.monitoring = false
	
	# Pastikan scene transition dilakukan dengan benar
	anim.play("open")

func _on_open_finished(anim_name: StringName):
	# Hanya proses jika animasi yang selesai adalah "open"
	if anim_name == "open":
		print("Door: ANIM FINISHED, loading scene")
		# Gunakan call_deferred untuk memastikan frame selesai sebelum ganti scene
		call_deferred("_change_scene")

func _change_scene():
	get_tree().change_scene_to_file(target_scene_path)
	print("=== CHANGING SCENE ===")
	print("From: ", get_tree().current_scene.name)
	print("To: ", target_scene_path)

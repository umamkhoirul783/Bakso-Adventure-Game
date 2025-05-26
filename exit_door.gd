extends Node2D

@export var outside_scene_path: String = "res://scene/Cuyrun.tscn"

@onready var anim            : AnimatedSprite2D  = $AnimatedSprite2D
@onready var blocker_shape   : CollisionShape2D  = $Blocker/CollisionShape2D
@onready var trigger         : Area2D            = $Trigger

var is_open   := false
var animating := false

func _ready():
	anim.play("closed")
	blocker_shape.disabled = false    # Shape start solid
	trigger.connect("body_entered", Callable(self, "_on_trigger_entered"))

func _on_trigger_entered(body):
	if body.is_in_group("player") and not animating:
		animating = true
		if not is_open:
			blocker_shape.disabled = true   # Disable only the shape
			anim.play("open")
		else:
			anim.play("closed")
		# connect once
		anim.connect("animation_finished", Callable(self, "_on_anim_finished"))

func _on_anim_finished(anim_name):
	animating = false
	if anim_name == "open":
		is_open = true
		get_tree().change_scene_to_file(outside_scene_path)
	else:
		is_open = false
		blocker_shape.disabled = false   # Re‑enable shape on close

extends Area2D

@onready var timer: Timer = $Timer

func _ready():
	# Connect signals in _ready, not in the signal function
	body_entered.connect(_on_body_entered)
	timer.timeout.connect(_on_timer_timeout)

func _on_body_entered(body: Node2D) -> void:
	# Check if it's the player using group instead of name
	if body.is_in_group("player"):
		print("Player entered kill zone!")
		# Kill player immediately or after a short delay
		if body.has_method("take_damage"):
			# Deal massive damage to kill player instantly
			body.take_damage(999)
		else:
			# Fallback: restart scene directly
			_kill_player()

func _kill_player():
	print("Player died from kill zone!")
	get_tree().change_scene_to_file("res://scene/GameOver.tscn")

func _on_timer_timeout() -> void:
	# This function can be used if you want a delay before killing
	_kill_player()

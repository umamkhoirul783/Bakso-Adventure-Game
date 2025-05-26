extends Area2D

@export var damage       : int    = 1
@export var target_group : String = "player"  # "player" or "enemies"

func _ready():
	monitoring = false
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group(target_group) and body.has_method("take_damage"):
		body.take_damage(damage)
		print("HitBox: Damaged ", body.name, " for ", damage, " damage")

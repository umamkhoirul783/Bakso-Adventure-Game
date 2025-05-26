extends HBoxContainer

@export var max_hearts : int = 3
var current_hearts : int = max_hearts

func _ready():
	update_hearts()

func update_hearts():
	for i in get_child_count():
		get_child(i).visible = (i < current_hearts)

func lose_heart():
	current_hearts = max(current_hearts - 1, 0)
	update_hearts()

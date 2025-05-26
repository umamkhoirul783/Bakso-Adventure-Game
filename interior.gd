extends Node2D

@export var outside_scene_path: String = "res://scene/Cuyrun.tscn"

@onready var spawn   : Marker2D = $SpawnPoint
@onready var wallet  : Area2D   = $WalletZone
@onready var exit_door: Node2D  = $ExitDoor

func _ready():
	# Tunggu sebentar untuk memastikan scene loading selesai
	await get_tree().process_frame
	
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0]
		# Pastikan posisi spawn point benar
		player.global_position = spawn.global_position
		print("Player spawned at: ", spawn.global_position)
	else:
		print("Error: Player tidak ditemukan dalam grup 'player'")

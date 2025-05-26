extends Area2D

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Dompet diambil!")
		# Hapus objek visual dompet jika ada, atau tampil UI:
		queue_free()

extends Area2D



func _on_body_entered(body: Node2D) -> void:
	print("+1 battery")
	queue_free() 
	Global.battery_count += 1
	print(Global.battery_count)

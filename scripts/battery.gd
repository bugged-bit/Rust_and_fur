extends Area2D

# Signal to notify that battery was collected
signal battery_collected

@export var battery_id: int = 1  # optional, if you want unique IDs

func _ready():
	# Connect the body_entered signal
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.name == "Cat":  # replace with your player node name
		# Emit signal to notify collection
		emit_signal("battery_collected", battery_id)
		
		# Print battery collected to output (Godot debugger)
		print("Battery +1 collected!")
		
		# Hide or remove the battery
		queue_free()

extends AnimatedSprite2D

@export var batteries_needed: int = 5
var battery_count: int = 0
var revived: bool = false

func add_battery() -> void:
	if revived:
		return
	battery_count += 1
	if battery_count >= batteries_needed:
		revive()

func revive() -> void:
	revived = true
	play("idle") # Idle animation will loop if it's set to loop in the editor

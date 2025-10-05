extends AnimatedSprite2D

@export var batteries_needed: int = 5
var battery_count: int = 0
var revived: bool = false

func add_battery() -> void:
	if revived:
		return
	
	battery_count += 1
	Global.battery_count += 1
	print("+1 battery collected! Total: %d/%d" % [Global.battery_count, batteries_needed])
	
	if battery_count >= batteries_needed:
		revive()

func revive() -> void:
	revived = true
	play("idle")  # switch to idle animation
	print("Robot revived! Now playing idle animation")

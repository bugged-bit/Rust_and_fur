extends Label
@onready var timer_2: Timer = $Timer2


func _ready():
	$Timer2.start()  # Start the timer when the scene loads
 

func _on_timer_2_timeout() -> void:
	hide()

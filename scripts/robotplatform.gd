extends AnimatableBody2D
@onready var robot: AnimatableBody2D = $AnimatedSprite2D


func _on_dialogue_end():
	# Play your end animation here
	$AnimatedSprite2D.play("end")

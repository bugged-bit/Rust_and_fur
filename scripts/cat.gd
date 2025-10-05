extends CharacterBody2D

# ------------------------
# SIGNALS
# ------------------------
signal inspect_pressed  # emit this when inspect key is pressed

# ------------------------
# NODES
# ------------------------
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# ------------------------
# CONSTANTS
# ------------------------
const SPEED = 300.0
const JUMP_VELOCITY = -300.0

# ------------------------
# VARIABLES
# ------------------------
var is_inspecting: bool = false

# ------------------------
# READY
# ------------------------
func _ready() -> void:
	animated_sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))

# ------------------------
# PHYSICS
# ------------------------
func _physics_process(delta: float) -> void:
	if is_inspecting:
		velocity.x = 0
		move_and_slide()
		return

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movement input
	var direction := Input.get_axis("move-left", "move-right")

	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	# Inspect
	if Input.is_action_just_pressed("inspect"):
		inspect()
		DialogueManager.show_dialogue_balloon(load("res://Dialogues/testing123.dialogue"), "start")


	# Play animations
	elif is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

	# Horizontal movement
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

# ------------------------
# INSPECT
# ------------------------
func inspect() -> void:
	is_inspecting = true
	animated_sprite.play("inspect")

# ------------------------
# ANIMATION FINISHED
# ------------------------
func _on_animation_finished() -> void:
	if animated_sprite.animation == "inspect":
		is_inspecting = false

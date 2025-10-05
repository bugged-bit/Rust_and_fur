# RobotEndController.gd
# Attach this to the Robot AnimatableBody2D

extends AnimatableBody2D

# AnimationPlayer that contains an animation named "end"
@onready var ap: AnimationPlayer = $AnimationPlayer

# Flag set from dialogue when the player selects "Yes"
var chose_yes: bool = false

func _ready() -> void:
	# Listen for the Dialogue Manager's end signal
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

# Called from dialogue as a mutation on the "Yes" option:
# -> set_chose_yes(true)
func set_chose_yes(val: bool) -> void:
	chose_yes = val

func _on_dialogue_ended(_res: DialogueResource) -> void:
	# Only play the end animation when the dialogue has fully concluded
	# and the player chose "Yes".
	if chose_yes and ap:
		ap.play("end")
	# Reset for the next run
	chose_yes = false

# Optional helper to start this robot's dialogue and ensure Dialogue Manager
# can find this node for mutations. Call this when interaction occurs.
func start_robot_dialogue() -> void:
	var res: DialogueResource = load("res://Dialogues/robot_question.dialogue")
	if res:
		# Pass this node so dialogue mutations (e.g., set_chose_yes) can resolve.
		DialogueManager.show_dialogue_balloon(res, "start", [self])

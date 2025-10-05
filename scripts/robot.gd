extends Node2D

# ------------------------
# EXPORTS
# ------------------------
@export var batteries_needed: int = 5
@export var dialogue_path_first: String = "res://Dialogues/robot_intro.dialogue"
@export var dialogue_path_second: String = "res://Dialogues/robot_question.dialogue"

# ------------------------
# NODE REFERENCES
# ------------------------
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area: Area2D = $Area2D
@onready var timer3: Timer = $Timer3

# ------------------------
# VARIABLES
# ------------------------
var battery_count: int = 0
var revived: bool = false
var player_in_range: bool = false

# ------------------------
# READY
# ------------------------
func _ready() -> void:
	print("Robot ready. Connecting Area2D signals...")
	interaction_area.connect("body_entered", Callable(self, "_on_area_entered"))
	interaction_area.connect("body_exited", Callable(self, "_on_area_exited"))
	print("Signals connected.")

	# Connect Cat's inspect signal
	var cat = get_node("/root/CurrentScene/Cat")  # Adjust path to your scene
	cat.connect("inspect_pressed", Callable(self, "_on_cat_inspect"))
	print("Connected to Cat's inspect_pressed signal.")

# ------------------------
# AREA SIGNALS
# ------------------------
func _on_area_entered(body):
	print("Body entered: ", body.name)
	if body.is_in_group("player"):
		player_in_range = true
		print("Player in range!")

func _on_area_exited(body):
	print("Body exited: ", body.name)
	if body.is_in_group("player"):
		player_in_range = false
		print("Player left range!")

# ------------------------
# CAT INSPECT SIGNAL
# ------------------------
func _on_cat_inspect():
	print("Cat pressed inspect!")
	if player_in_range:
		start_dialogue()
	else:
		print("But Cat is not in range.")

# ------------------------
# BATTERY LOGIC
# ------------------------
func add_battery() -> void:
	if revived:
		print("Battery collected, but robot already revived.")
		return
	
	battery_count += 1
	Global.battery_count += 1
	print("+1 battery collected! Total: %d/%d" % [battery_count, batteries_needed])

	if battery_count >= batteries_needed:
		revive()

func revive() -> void:
	revived = true
	sprite.play("idle")
	print("Robot revived!")
	# Optional: trigger Timer3 or visual effects here

# ------------------------
# DIALOGUE LOGIC
# ------------------------
func start_dialogue():
	print("Attempting to start dialogue...")
	var dialogue_resource = null

	if Global.robot_met_before:
		dialogue_resource = load(dialogue_path_second)
	else:
		dialogue_resource = load(dialogue_path_first)

	if dialogue_resource == null:
		push_warning("Dialogue file not found at path: %s" % (dialogue_path_first if not Global.robot_met_before else dialogue_path_second))
		return

	if Global.robot_met_before:
		print("Starting second dialogue (question)...")
		DialogueManager.show_dialogue_from_id(dialogue_resource, "start")
	else:
		print("Starting first dialogue (intro)...")
		DialogueManager.show_dialogue(dialogue_resource)
		Global.robot_met_before = true

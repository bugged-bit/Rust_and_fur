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
	# Connect signals for player proximity
	interaction_area.connect("body_entered", Callable(self, "_on_area_entered"))
	interaction_area.connect("body_exited", Callable(self, "_on_area_exited"))

# ------------------------
# AREA SIGNALS
# ------------------------
func _on_area_entered(body):
	if body.is_in_group("player"):
		player_in_range = true

func _on_area_exited(body):
	if body.is_in_group("player"):
		player_in_range = false

# ------------------------
# PROCESS INPUT
# ------------------------
func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("inspect"):
		start_dialogue()

# ------------------------
# BATTERY LOGIC
# ------------------------
func add_battery() -> void:
	if revived:
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
	# Optional: you can trigger Timer3 or visual effects here

# ------------------------
# DIALOGUE LOGIC
# ------------------------
func start_dialogue():
	var dialogue_resource = null

	if Global.robot_met_before:
		dialogue_resource = load(dialogue_path_second)
	else:
		dialogue_resource = load(dialogue_path_first)

	if dialogue_resource == null:
		push_warning("Dialogue file not found at path: %s" % (dialogue_path_first if not Global.robot_met_before else dialogue_path_second))
		return

	if Global.robot_met_before:
		DialogueManager.show_dialogue_from_id(dialogue_resource, "start")
	else:
		DialogueManager.show_dialogue(dialogue_resource)
		Global.robot_met_before = true

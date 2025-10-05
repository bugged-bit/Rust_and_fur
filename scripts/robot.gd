extends Node2D
# Robot NPC that listens for the player's "inspect" signal only when the player
# is inside this node's Area2D, then starts a dialogue resource accordingly.

# --- Editable properties shown in the Inspector ---
@export var batteries_needed: int = 5
@export var dialogue_path_first: String = "res://Dialogues/robot_intro.dialogue"
@export var dialogue_path_second: String = "res://Dialogues/robot_question.dialogue"

# --- Node references (filled when the scene is ready) ---
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area: Area2D = $Area2D
@onready var timer3: Timer = $Timer3

# --- Constants/State ---
const PLAYER_GROUP := "player"  # The Cat node must be in this group via the editor.
var battery_count: int = 0
var revived: bool = false
var player_in_range: bool = false
var cat: Node = null  # Will point to the Cat while inside the Area2D.

func _ready() -> void:
	# Wire Area2D proximity signals in code; this is the canonical way to react
	# when scenes are instanced and to avoid editor-only connections.
	# (body_entered/body_exited are signals on Area2D.)
	interaction_area.body_entered.connect(_on_area_entered)
	interaction_area.body_exited.connect(_on_area_exited)

func _on_area_entered(body: Node) -> void:
	# Only track bodies that belong to the "player" group (the Cat).
	if body.is_in_group(PLAYER_GROUP):
		player_in_range = true
		cat = body
		# Connect exactly once to the Cat's custom signal emitted on Inspect.
		if not cat.is_connected("inspect_pressed", Callable(self, "_on_cat_inspect")):
			cat.connect("inspect_pressed", Callable(self, "_on_cat_inspect"))

func _on_area_exited(body: Node) -> void:
	# When the same Cat leaves, stop listening for its inspect presses.
	if body == cat:
		player_in_range = false
		if cat.is_connected("inspect_pressed", Callable(self, "_on_cat_inspect")):
			cat.disconnect("inspect_pressed", Callable(self, "_on_cat_inspect"))
		cat = null

func _exit_tree() -> void:
	# Safety: if the scene is freed while still connected, disconnect cleanly.
	if cat and cat.is_connected("inspect_pressed", Callable(self, "_on_cat_inspect")):
		cat.disconnect("inspect_pressed", Callable(self, "_on_cat_inspect"))

func _on_cat_inspect() -> void:
	# Only react to Inspect while the player is in range.
	if player_in_range:
		start_dialogue()

func add_battery() -> void:
	# Robot revives after enough batteries; early-out if already revived.
	if revived:
		return
	battery_count += 1
	Global.battery_count += 1
	if battery_count >= batteries_needed:
		revive()

func revive() -> void:
	# Minimal revive feedback; play an idle animation if present.
	revived = true
	if sprite:
		sprite.play("idle")

func start_dialogue() -> void:
	# Choose which dialogue file to show based on a global flag.
	var res_path: String = dialogue_path_second if Global.robot_met_before else dialogue_path_first
	# Load the .dialogue resource expected by the DialogueManager addon.
	var res := load(res_path)
	if res == null:
		return
	# First time: open default dialogue; afterwards, jump to an id in the second file.
	if Global.robot_met_before:
		DialogueManager.show_dialogue_from_id(res, "start")
	else:
		DialogueManager.show_dialogue(res)
		Global.robot_met_before = true

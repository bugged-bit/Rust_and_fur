extends Node2D

@export var batteries_needed: int = 5
@export var dialogue_path: String = "res://dialogues/robot.dialogue"

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area: Area2D = $Area2D

var battery_count: int = 0
var revived: bool = false
var player_near: bool = false
@export var dialogue_path_first: String = "res://dialogues/robot_intro.dialogue"
@export var dialogue_path_second: String = "res://dialogues/robot_question.dialogue"


func _ready() -> void:
	area.connect("body_entered", Callable(self, "_on_body_entered"))
	area.connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_near = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_near = false

func _process(_delta):
	if player_near and Input.is_action_just_pressed("inspect"):
		_start_dialogue()

func add_battery() -> void:
	if revived:
		return

	battery_count += 1
	Global.battery_count += 1
	print("+1 battery collected! Total: %d/%d" % [battery_count, batteries_needed])

	if battery_count >= batteries_needed:
		_revive()

func _revive() -> void:
	revived = true
	sprite.play("idle")
	print("Robot revived! Now playing idle animation")

func _start_dialogue():
	var dialogue = load(dialogue_path)
	if dialogue == null:
		push_warning("Dialogue file not found at path: %s" % dialogue_path)
		return

	if Global.robot_met_before:
		DialogueManager.show_dialogue_from_id(dialogue, "question")
	else:
		DialogueManager.show_dialogue(dialogue)
		Global.robot_met_before = true

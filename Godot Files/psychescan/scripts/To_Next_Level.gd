extends Area2D

@export var new_scene_path: String = "res://Typing Level/TypingLevel.tscn" # NEXT LEVEL NAME HERE
@onready var label
var textDone = false

func _ready():
	monitoring = true
	label = get_parent().get_node("Label")

func _process(delta: float) -> void:
	if !textDone: # Auto text effect
		if label.get_visible_ratio() < 1:
			label.set_visible_ratio(label.get_visible_ratio()+(.5*delta))
		else:
			textDone = true

	if Input.is_action_just_pressed("ui_accept"): # Press enter to go to next minigame
		get_tree().change_scene_to_file(new_scene_path)

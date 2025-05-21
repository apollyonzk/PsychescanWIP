extends Area2D

@export var new_scene_path: String = "res://psychescan/levels/level.tscn"
@onready var label
var textDone = false
var correctSound 
var correctNode


func _ready():
	monitoring = true
	label = get_parent().get_node("Label")
	correctSound = get_parent().get_node("CorrectSound")
	correctNode = get_parent().get_node("Correct")
	correctNode.visible = false


func _process(delta: float) -> void:
	# This section handles text auto type effect
	if !textDone:
		if label.get_visible_ratio() < 1:
			label.set_visible_ratio(label.get_visible_ratio()+(.15*delta))
		else:
			textDone = true

	# Press enter to begin the scan levels
	if Input.is_action_just_pressed("ui_accept"):
		var tree = get_tree()
		show_correct_node()
		correctSound.play()
		await correctSound.finished
		tree.change_scene_to_file(new_scene_path)

# Display correct indicator for the first time
func show_correct_node():
	correctNode.visible = true
	await(get_tree().create_timer(2.0).timeout)
	correctNode.visible = false

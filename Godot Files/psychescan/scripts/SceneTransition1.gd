extends Area2D

@export var new_scene_path: String = "res://psychescan/levels/level2.tscn"
#@export var new_scene_path: String

# Tracks the player object currently in the area
var is_overlap = false # Used to track if player is aligned with the correct area
var is_prox_overlap = false # Used to track if player is in proximity of the correct area
var player_node: CharacterBody2D = null
var correctNode
var incorrectNode
var is_scene_change_pending = false
var correctSound
var incorrectSound
var prox_node: Area2D = null
@onready var label
var textDone = false
var is_beeping: bool = true

# Variables for beep sound (proximity sensor)
@export var near_beep_delay: float = 0.2  # fastest beep rate (seconds)
@export var far_beep_delay: float = 1.0  # slowest beep rate (seconds)
@onready var beep_audio: AudioStreamPlayer = $BeepAudio

func _ready():
	monitoring = true
	correctNode = get_parent().get_node("Correct")
	incorrectNode = get_parent().get_node("Incorrect")
	correctNode.visible = false
	incorrectNode.visible = false
	correctSound = get_parent().get_node("CorrectSound")
	incorrectSound = get_parent().get_node("IncorrectSound")
	label = get_parent().get_node("Label")
	beep_loop()

# Signals for collision detection (if reticle is aligned properly)
func _on_area2d_body_entered(body):
	if body is CharacterBody2D: 
		player_node = body
		is_overlap = true

func _on_area2d_body_exited(body):
	if body == player_node:
		player_node = null
		is_overlap = false

# These area flags detect proximity of the player to the target area, which is used to change the beep rate of the proximity sensor
func _on_area2d_area_entered(area: Area2D) -> void: 
	is_prox_overlap = true
	prox_node = area

func _on_area2d_area_exited(area: Area2D) -> void:
	if area == prox_node:
		is_prox_overlap = false
		prox_node = null

# This function handles the beeping sound of the proximity sensor
# It plays a sound at a set interval, which is changed based on the proximity of the player to the target area
func beep_loop() -> void:
	while is_beeping:
		var delay = far_beep_delay
		if is_prox_overlap or is_overlap:
			delay = near_beep_delay
		beep_audio.play()
		await(get_tree().create_timer(delay).timeout)


func _process(delta: float) -> void:
	# Auto Type effect
	if !textDone:
		if label.get_visible_ratio() < 1:
			label.set_visible_ratio(label.get_visible_ratio()+(.5*delta))
		else:
			textDone = true

	# This section handles scanning behavior		
	if is_overlap and Input.is_action_just_pressed("ui_accept"): # If the player is aligned with the target area and presses enter
		is_beeping = false
		var ani = player_node.get_node("AnimatedSprite2D")
		ani.queue_free() # Removes sparkle effect from already-scanned box
		show_correct_indicator()
		correctSound.play()
		await correctSound.finished
		is_overlap = false
		is_scene_change_pending = true
	elif not is_overlap and Input.is_action_just_pressed("ui_accept"):
		show_incorrect_indicator()
		incorrectSound.play()
		await incorrectSound.finished


# Method to move to next level
func change_scene():
	var tree = get_tree()
	if new_scene_path.length() == 0:
		return
		
	var result = tree.change_scene_to_file(new_scene_path)


# Displays an indicator for 2 seconds for a correct or incorrect scan
func show_correct_indicator():
	correctNode.visible = true
	await(get_tree().create_timer(2.0).timeout)  # Wait for 2 seconds
	correctNode.visible = false
	if is_scene_change_pending:
		change_scene() # Scene is changed here because scene would change too fast to display the indicator if used in _process.

func show_incorrect_indicator():
	incorrectNode.visible = true
	await(get_tree().create_timer(1.25).timeout)
	incorrectNode.visible = false

extends Area2D

@export var new_scene_path: String = "res://psychescan/levels/victory_scene.tscn"
# Tracks the player object currently in the area
var is_overlap = false
var is_prox_overlap = false # Used to track if player is in proximity of the correct area
var player_node: CharacterBody2D = null
var overlapping_box: CollisionShape2D = null
var valid_scan_count: int = 0
var scanned_boxes := []  # List to keep track of scanned boxes
var correctNode
var incorrectNode
var is_scene_change_pending = false
var correctSound
var incorrectSound
@onready var label
var textDone = false
var prox_node: Area2D = null
var is_beeping: bool = true

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
		overlapping_box = find_collision_box(body)
		if overlapping_box:
			is_overlap = true
			
func _on_area2d_body_exited(body):
	if body == player_node:
		player_node = null
		is_overlap = false
		overlapping_box = null

# Signals for proximity detection
func _on_area2d_area_entered(area: Area2D) -> void:
	is_prox_overlap = true
	prox_node = area

func _on_area2d_area_exited(area: Area2D) -> void:
	if area == prox_node:
		is_prox_overlap = false
		prox_node = null

# Proximity sensor beep sound
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

	if is_overlap and Input.is_action_just_pressed("ui_accept"):
		if overlapping_box and not has_been_scanned(overlapping_box):
			scanned_boxes.append(overlapping_box) # Scanned boxes are added to list so player cannot use them again
			valid_scan_count += 1
			is_overlap = false
			is_prox_overlap = false
			var ani = player_node.get_node("AnimatedSprite2D")
			ani.queue_free() # Remove sparkle effect
			prox_node.get_parent().remove_child(prox_node) # Removes prox hitbox to stop beeping
			show_correct_only()
			correctSound.play()
			await correctSound.finished

			if valid_scan_count == 3: # When player has scanned all target areas
				is_scene_change_pending = true
				show_correct_indicator()
				is_beeping = false

		elif overlapping_box and has_been_scanned(overlapping_box):
			show_incorrect_indicator()
			incorrectSound.play()
			await incorrectSound.finished

	elif not is_overlap and Input.is_action_just_pressed("ui_accept"):
		show_incorrect_indicator()
		incorrectSound.play()
		await incorrectSound.finished

func change_scene():
	var tree = get_tree()
	if new_scene_path.length() == 0:
		return
		
	var result = tree.change_scene_to_file(new_scene_path)

# Tracks the target area that the player is currently overlapping when multiple targets are present		
func find_collision_box(player: CharacterBody2D) -> CollisionShape2D:
	for child in player.get_children():
		if child is CollisionShape2D and not has_been_scanned(child):
			return child
	return null		

# Check if player has already scanned the box
func has_been_scanned(box: CollisionShape2D) -> bool:
	return box in scanned_boxes

# Displays an indicator for 2 seconds for a correct or incorrect scan
func show_correct_indicator():
	correctNode.visible = true
	await(get_tree().create_timer(2.0).timeout)
	correctNode.visible = false
	if is_scene_change_pending:
		change_scene()

# Display correct indicator without changing scene
func show_correct_only():
	correctNode.visible = true
	await(get_tree().create_timer(2.0).timeout)
	correctNode.visible = false

func show_incorrect_indicator():
	incorrectNode.visible = true
	await(get_tree().create_timer(1.25).timeout) 
	incorrectNode.visible = false

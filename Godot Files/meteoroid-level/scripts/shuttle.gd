# script for the shuttle and its movement

extends CharacterBody2D

signal meteoroid_movement # signal for meteoroids when the shuttle moves

const MOVE = 1 # number of tiles to move
var MAX_MOVES = 20
var tile_size = 128
var animation_speed = 1.5
var moving = false
var target_tile = (Vector2(8, -1) * tile_size) + (Vector2.ONE * tile_size/2)
var animation_tile = Vector2(-5, -1) * tile_size
var starting_tile = Vector2(0, -1) * tile_size # starting tile for the game
var turn_angle = PI / 2 # 90 degrees in radians for ship rotation

var inputs = {"ui_right": Vector2.RIGHT, # directional inputs using arrow keys
"ui_left": Vector2.LEFT,
"ui_up": Vector2.UP,
"ui_down": Vector2.DOWN}

# shuttle script holds path to nodes in the current level
@onready var path: Line2D = $"../Path"
@onready var movement_sound: AudioStreamPlayer2D = $MovementSound


var input_array = [] # array to store inputs

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = animation_tile
	position += Vector2.ONE * tile_size/2  # centers shuttle in tile
	
	
	#  animation for shuttle to move to starting tile
	var tween = create_tween()
	tween.tween_property(self, "position", starting_tile + (Vector2.ONE * tile_size/2), 1.0/animation_speed).set_trans(Tween.TRANS_SINE) # set starting tile
	moving = true
	await tween.finished
	moving = false

func _unhandled_input(event: InputEvent) -> void:
	if moving:
		return # restricts input until move complete
	for dir in inputs.keys(): # checks through list of allowed inputs to store into array
		if event.is_action_pressed(dir):
			add_input(dir)
	if event.is_action_pressed("ui_cancel"): # backspace and escape
		remove_input()
	if event.is_action_pressed("ui_accept"): # if user presses enter to finalize inputs
		if input_array.is_empty():
			return
		move()

func move():
	var last_dir = input_array.front() # variable for movement animation
	moving = true; # restricts further input
	movement_sound.play()
	for dir in input_array:
		call_meteoroids_move() # signals to meteoroids
		
		var tween = create_tween()
		if last_dir == dir:
			tween.tween_property(self, "position", position + inputs[dir] * tile_size * MOVE, 1.0/animation_speed) # straight movement speed
		else:
			tween.tween_property(self, "position", position + inputs[dir] * tile_size * MOVE, 1.0/animation_speed).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE) # slower on turns
			rotateShuttle(dir, last_dir)
		await tween.finished
		last_dir = dir
	movement_sound.stop()
	win_condition() # check to see if shuttle is at target tile
	
	
func rotateShuttle(dir: String, last_dir: String) -> void: # shuttle rotates 90 degrees at corners, does not rotate for 180 degree changes
	# could possibly be improved instead of doing each scenario
	if dir == "ui_right" && last_dir == "ui_up" || dir == "ui_down" && last_dir == "ui_right" || dir == "ui_left" && last_dir == "ui_down" || dir == "ui_up" && last_dir == "ui_left":
		var tween = create_tween()
		tween.tween_property(self, "rotation", rotation + turn_angle, 1.0/animation_speed) # clockwise rotation
	else:
		if dir == "ui_right" && last_dir == "ui_down" || dir == "ui_up" && last_dir == "ui_right" || dir == "ui_left" && last_dir == "ui_up" || dir == "ui_down" && last_dir == "ui_left":
			var tween = create_tween()
			tween.tween_property(self, "rotation", rotation - turn_angle, 1.0/animation_speed) # counterclockwise rotation


func call_meteoroids_move() -> void:
	emit_signal("meteoroid_movement")
	
func add_input(dir: String) -> void:
	if input_array.size() < MAX_MOVES: # number of inputs limited per level
		if(path.trace(dir)): # if the path can be drawn
			input_array.append(dir)

func remove_input() -> void: # removes the most recent input from the movement array, the arrow array, and the path
	input_array.pop_back()
	path.remove_last_point()

func win_condition() -> void:
	var current_level = get_tree().get_current_scene() # retrieves the current level's node
	if position == target_tile: # checks if the shuttle is at the target tile for a win
		current_level.win_screen() # transition to next level
	else:
		current_level.lose_screen() # reset level


# SETTING LEVEL LIMITS AND GOAL TILES, CALLED BY LEVEL NODES

func level_1_changes() -> void:
	MAX_MOVES = 10
	target_tile = (Vector2(4, -1) * tile_size) + (Vector2.ONE * tile_size/2)


func level_2_changes() -> void:
	MAX_MOVES = 15
	target_tile = (Vector2(6, -1) * tile_size) + (Vector2.ONE * tile_size/2)
	
func level_3_changes() -> void:
	MAX_MOVES = 20
	target_tile = (Vector2(8, -1) * tile_size) + (Vector2.ONE * tile_size/2)

# script for path tracing of inputs

extends Line2D

const MOVE = 1 # number of tiles to move

var tile_size = 128
var starting_tile = (Vector2(0, -1) * tile_size) + Vector2.ONE * tile_size/2 # centers line

var visited_lines = {} # dictionary to store path's current tile and the next input tile location

var inputs = {"ui_right": Vector2.RIGHT, # directional inputs using arrow keys
"ui_left": Vector2.LEFT,
"ui_up": Vector2.UP,
"ui_down": Vector2.DOWN}

var last_tile = starting_tile # same in the beginning

@onready var ray_cast_2d: RayCast2D = $RayCast2D



func _ready() -> void:
	add_point(starting_tile) # sets path's starting location
	ray_cast_2d.position = starting_tile # moves path's raycast node to tile


func trace(dir: String):
	var step = inputs[dir] * tile_size * MOVE # sets length of input
	ray_cast_2d.target_position = step # moves the ray to new position and checks if it is against a border, restricts movements
	ray_cast_2d.force_raycast_update() 
	if !ray_cast_2d.is_colliding(): # if input is not against a border
		add_point(last_tile + step) # add next movement to path
		
		var pair = [last_tile, last_tile + step] # array with previous tile and current tile
		pair.sort() # sort the array so it would be the same for any direction
		
		if visited_lines.has(pair): # if dictionary has pair-key, append an overlapping line child
			visited_lines[pair].append(create_overlap(last_tile, last_tile + step))
		else: # if dictionary does not have this pair, create an empty array for pair so pair-key exists
			visited_lines[pair] = []
		
		last_tile = get_point_position(get_point_count() - 1)
		ray_cast_2d.position = last_tile # sets raycast to new position
		ray_cast_2d.force_raycast_update()
		return true # returns true or false so shuttle knows to create an input arrow to display
	return false

func remove_last_point() -> void:
	if get_point_count() > 1: # first point is starting tile, do not remove
		
		var step = get_point_position(get_point_count() - 1) # get most recent tile for delete
		
		remove_point(get_point_count() - 1) # remove most recent tile
		last_tile = get_point_position(get_point_count() - 1) # get the current existing tile
		ray_cast_2d.position = last_tile # set path's raycast to previous tile
		
		remove_overlap(last_tile, step) # check to see if overlapping line needs to be removed


func create_overlap(point_a: Vector2, point_b: Vector2):
	var overlap_line = Line2D.new() # create a line2d child
	overlap_line.default_color = Color(0.792, 0.298, 0.38) # set line color to Psyche color (pink)
	
	# create line by connecting the two points
	overlap_line.add_point(point_a)
	overlap_line.add_point(point_b)
	
	add_child(overlap_line)
	
	return overlap_line # returns line for visited pair array

func remove_overlap(point_a: Vector2, point_b: Vector2) -> void:
	var pair = [point_a, point_b]
	pair.sort()
	
	if visited_lines.has(pair): # checks if the pair is in dictionary
		if !visited_lines[pair].is_empty(): # if the value array is not empty, pop the last line in array (most recent)
			var overlap_line = visited_lines[pair].pop_back()
			overlap_line.queue_free()
		else:
			visited_lines.erase(pair) # removes pair-key from dictionary if no overlapping lines

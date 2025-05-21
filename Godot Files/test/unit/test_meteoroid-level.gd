# unit test file for meteoroid level

extends GutTest

var Shuttle = preload("res://meteoroid-level/scripts/shuttle.gd")
var Path = preload("res://meteoroid-level/scripts/path.gd")
var Moving_debris = preload("res://meteoroid-level/scenes/moving_debris.tscn")
var Input_container = preload("res://meteoroid-level/scripts/input_container.gd")
var Killzone = preload("res://meteoroid-level/scenes/killzone.tscn")
var Level_1 = preload("res://meteoroid-level/scenes/level_1.tscn")
var Level_1_screen = preload("res://meteoroid-level/scenes/level_1_screen.tscn")
var Level_2 = preload("res://meteoroid-level/scenes/level_2.tscn")
var Level_2_screen = preload("res://meteoroid-level/scenes/level_2_screen.tscn")
var Level_3 = preload("res://meteoroid-level/scenes/level_3.tscn")
var Level_3_screen = preload("res://meteoroid-level/scenes/level_3_screen.tscn")
var Start_screen = preload("res://meteoroid-level/scenes/start_screen.tscn")
var End_screen = preload("res://meteoroid-level/scenes/end_screen.tscn")

var _shuttle = null
var _path = null
var _moving_debris = null
var _input_container = null
var _killzone = null
var _level_1 = null
var _level_1_screen = null
var _level_2 = null
var _level_2_screen = null
var _level_3 = null
var _level_3_screen = null
var _start_screen = null
var _end_screen = null

const MOVE = 1
var MAX_MOVES = 20
var tile_size = 128
var animation_speed = 1
var moving = false
var target_tile = (Vector2(8, -1) * tile_size) + (Vector2.ONE * tile_size/2)
var animation_tile = Vector2(-5, -1) * tile_size
var starting_tile = Vector2(0, -1) * tile_size


var shuttledouble = null

func before_each():
	_shuttle = Shuttle.new()
	_path = double(Path).new()
	#_moving_debris = Moving_debris.instantiate()
	_input_container = Input_container.new()
	#_killzone = Killzone.instantiate()
	#_level_1 = Level_1.instantiate()
	#_level_1_screen = Level_1_screen.instantiate()
	#_level_2 = Level_2.instantiate()
	#_level_2_screen =Level_2_screen.instantiate()
	#_level_3 = Level_3.instantiate()
	#_level_3_screen = Level_3_screen.instantiate()
	#_start_screen = Start_screen.instantiate()
	#_end_screen = End_screen.instantiate()
	
	add_child(_shuttle)
	add_child(_path)
	#add_child(_moving_debris)
	add_child(_input_container)
	#add_child(_killzone)
	#add_child(_level_1)
	#add_child(_level_1_screen)
	#add_child(_level_2)
	#add_child(_level_2_screen)
	#add_child(_level_3)
	#add_child(_level_3_screen)
	#add_child(_start_screen)
	#add_child(_end_screen)
	
	_shuttle.path = _path
	_shuttle.movement_sound = AudioStreamPlayer2D.new()
	_shuttle.input_container = _input_container
	stub(_path.trace).to_return(true)
	
	shuttledouble = double(Shuttle).new()
	shuttledouble.path = _path
	shuttledouble.input_container = _input_container
	stub(shuttledouble._unhandled_input).to_call_super()
	stub(shuttledouble.add_input).to_call_super()
	
	
	
	
	await get_tree().process_frame

func after_each():
	
	
	_shuttle.queue_free()
	_path.free()
	#_moving_debris.free()
	_input_container.free()
	#_killzone.free()
	#_level_1.free()
	#_level_1_screen.free()
	#_level_2.free()
	#_level_2_screen.free()
	#_level_3.free()
	#_level_3_screen.free()
	#_start_screen.free()
	#_end_screen.free()
	
	shuttledouble.free()
	
	await get_tree().process_frame

# tests for shuttle node

func test_shuttle_initial_position_before_animation():
	assert_eq(_shuttle.position, animation_tile + (Vector2.ONE * tile_size/2), "Shuttle should start at this tile before animation")

func test_shuttle_initial_position_after_animation():
	await get_tree().create_timer(2).timeout
	assert_eq(_shuttle.position, starting_tile + (Vector2.ONE * tile_size/2), "Shuttle should start at this tile after animation")

func test_move_input():
	#await get_tree().create_timer(1.0/animation_speed).timeout
	_shuttle.moving = false
	var event = InputEventAction.new()
	event.action = "ui_right"
	event.pressed = true
	
	_shuttle._unhandled_input(event)
	
	event.action = "ui_left"
	_shuttle._unhandled_input(event)
	
	event.action = "ui_up"
	_shuttle._unhandled_input(event)
	
	event.action = "ui_down"
	_shuttle._unhandled_input(event)
	
	assert_eq(_shuttle.input_array.size(), 4, "input array should be incremented to 4, 1 for each direction")

func test_move_input_while_moving():
	#await get_tree().create_timer(1.0/animation_speed).timeout
	_shuttle.moving = true
	var event = InputEventAction.new()
	event.action = "ui_right"
	event.pressed = true
	
	_shuttle._unhandled_input(event)
	
	assert_eq(_shuttle.input_array.size(), 0, "input array should not be incremented while moving")


func test_delete_input():
	#await get_tree().create_timer(1.0/animation_speed).timeout
	_shuttle.moving = false
	var event = InputEventAction.new()
	event.action = "ui_right"
	event.pressed = true
	
	_shuttle._unhandled_input(event)
	_shuttle._unhandled_input(event)
	
	event.action = "ui_cancel"
	_shuttle._unhandled_input(event)
	
	assert_eq(_shuttle.input_array.size(), 1, "input array should decrement to 1")

func test_delete_input_on_empty_array():
	#await get_tree().create_timer(1.0/animation_speed).timeout
	_shuttle.moving = false
	var event = InputEventAction.new()
	event.pressed = true
	
	event.action = "ui_cancel"
	_shuttle._unhandled_input(event)
	
	assert_eq(_shuttle.input_array.size(), 0, "input array size should stay at 0")


func test_enter_on_valid_inputs():
	#await get_tree().create_timer(1.0/animation_speed).timeout
	
	shuttledouble.moving = false
	var event = InputEventAction.new()
	event.pressed = true
	
	event.action = "ui_right"
	shuttledouble._unhandled_input(event)
	
	event.action = "ui_accept"
	shuttledouble._unhandled_input(event)
	
	assert_called(shuttledouble, "move")

func test_enter_on_empty_inputs():
	#await get_tree().create_timer(1.0/animation_speed).timeout
	
	shuttledouble.moving = false
	var event = InputEventAction.new()
	event.pressed = true
	
	event.action = "ui_accept"
	shuttledouble._unhandled_input(event)
	
	assert_not_called(shuttledouble, "move")


func test_move():
	watch_signals(_shuttle)
	_shuttle.moving = false
	var event = InputEventAction.new()
	event.pressed = true
	
	event.action = "ui_right"
	_shuttle._unhandled_input(event)
	
	event.action = "ui_accept"
	_shuttle._unhandled_input(event)
	
	assert_signal_emitted(_shuttle, "meteoroid_movement", "should call signal")

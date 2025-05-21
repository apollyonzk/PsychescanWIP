extends GutTest

const TEST_SCENE_PATH := "res://scavenger-hunt/scenes/launch.tscn" # Update to real scene path

var scene_instance

func before_each():
	scene_instance = preload(TEST_SCENE_PATH).instantiate()
	add_child(scene_instance)

func after_each():
	if scene_instance.is_inside_tree():
		scene_instance.get_parent().remove_child(scene_instance)
	scene_instance.queue_free()
	await get_tree().process_frame  # Let Godot free it next frame

func test_streaming_prelaunch():
	assert_eq(scene_instance.get_node("VideoStreamPlayer").stream, scene_instance.prelaunch)

func test_prelaunch_playing():
	assert_true(scene_instance.get_node("VideoStreamPlayer").is_playing())

func test_prelaunch_looping():
	assert_true(scene_instance.get_node("VideoStreamPlayer").loop)

func test_line_starting_position():
	assert_eq(scene_instance.get_node("Meter/LineArea").position.y, 30.0)

func test_start_direction():
	assert_eq(scene_instance.direction, "down")
	
func test_instructions_start():
	assert_true(scene_instance.top_start)
	
func test_input_not_allowed_until_dialogue_end():
	assert_false(scene_instance.input_allowed)

func test_line_moves_down_at_first():
	scene_instance._process(0.1)
	assert_eq(scene_instance.direction, "down")
	assert_gt(scene_instance.get_node("Meter/LineArea").position.y, 30.0)

func test_line_position_at_bottom():
	scene_instance.get_node("Meter/LineArea").position.y = 800.0
	await scene_instance.hit_end
	assert_eq(scene_instance.get_node("Meter/LineArea").position.y, 810.0)

func test_direction_changes_at_bottom():
	scene_instance.get_node("Meter/LineArea").position.y = 800.0
	await scene_instance.hit_end
	assert_eq(scene_instance.direction, "up")

func test_line_moves_up_after_bottom():
	scene_instance.get_node("Meter/LineArea").position.y = 800.0
	await scene_instance.hit_end
	scene_instance._process(0.1)
	assert_lt(scene_instance.get_node("Meter/LineArea").position.y, 810.0)

func test_line_position_at_top():
	scene_instance.direction = "up"
	await scene_instance.hit_end
	assert_eq(scene_instance.get_node("Meter/LineArea").position.y, 0.0)

func test_direction_changes_at_top():
	scene_instance.direction = "up"
	await scene_instance.hit_end
	assert_eq(scene_instance.direction, "down")

func test_line_moves_down_after_top():
	scene_instance.direction = "up"
	await scene_instance.hit_end
	scene_instance._process(0.1)
	assert_eq(scene_instance.direction, "down")
	assert_gt(scene_instance.get_node("Meter/LineArea").position.y, 0.0)

func test_valid_set_to_true_on_green_area_entered():
	scene_instance._on_green_area_area_entered(null)
	assert_true(scene_instance.valid)
#
func test_valid_set_to_false_on_red_area_entered():
	scene_instance._on_red_area_area_entered(null)
	assert_false(scene_instance.valid)

func test_input_allowed_after_dialogue_end():
	scene_instance.base_speed = 200
	scene_instance.auto_advance_delay = 0.0
	await scene_instance.dialogue_end
	assert_true(scene_instance.input_allowed)

func test_successful_launch_changes_video():
	scene_instance.base_speed = 200
	scene_instance.auto_advance_delay = 0.0
	await scene_instance.dialogue_end
	assert_true(scene_instance.input_allowed)

	scene_instance.direction = "down"
	scene_instance.get_node("Meter/LineArea").position.y = 280

	# Simulate pressing the input
	var event := InputEventAction.new()
	event.pressed = true
	event.action = "ui_accept"  
	scene_instance._unhandled_input(event)
	
	assert_true(scene_instance.valid)
#
	#await get_tree().process_frame
	#assert_eq(scene_instance.top_label.text, "Well done")
	#assert_true(scene_instance.get_node("Instructions/Bottom").visible)
	#assert_true(scene_instance.get_node("Meter").visible)
#
	## Wait for the scene to switch video
	await get_tree().create_timer(10.0).timeout
	#await get_tree().process_frame
	#
	#var video_player = scene_instance.get_node("VideoStreamPlayer")
	#assert_eq(video_player.stream, scene_instance.launch)
	#assert_true(video_player.is_playing())
	#assert_false(video_player.loop)

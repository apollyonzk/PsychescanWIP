extends Control

const prelaunch = preload("res://launch/assets/prelaunch.ogv")
const launch = preload("res://launch/assets/launch.ogv")

var direction
var valid
var input_allowed := false
signal hit_end
signal dialogue_end

var base_speed := 20
var count := 0.0
var auto_advance_timer := 0.0
var auto_advance_delay := 2.0  # Seconds to wait after line fully shown
var top_text = [
		"Greetings Kuiper",
		"Your first task is to launch the SpaceX Falcon Heavy rocket",
		"Controls:\n[Enter]\n[Space]",
		]
@onready var top_label := $Instructions/Top
var top_started := true
var top_finished := false
var top_start = false
var bottom_text = [
		"Launch the rocket when the black line is in the green area",
		]
@onready var bottom_label := $Instructions/Bottom
var bottom_started := true
var bottom_finished := false
var bottom_start = false

var win = false
var win_triggered = false

func _ready() -> void:
	$Meter.hide()
	$Meter/LineArea.position.y = 30
	$VideoStreamPlayer.stream = prelaunch
	$VideoStreamPlayer.play()
	$VideoStreamPlayer.loop = true
	direction = "down"
	top_start = true

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept") and input_allowed:
		if valid:
			win = true
			_on_win()
		else:
			$AnimationPlayer.play("flash_wrong")

func _process(delta: float) -> void:
	if !win:
		if (direction == "down"):
			if ($Meter/LineArea.position.y >= 0):
				$Meter/LineArea.position.y += 10
			if ($Meter/LineArea.position.y == 810):
				direction = "up"
				hit_end.emit()
		if (direction == "up"):
			if ($Meter/LineArea.position.y <= 810):
				$Meter/LineArea.position.y -= 10
			if ($Meter/LineArea.position.y == 0):
				direction = "down"
				hit_end.emit()

	if (top_start):
		if top_label.get_visible_ratio() != 1.0:
			if count < 1:
				count += base_speed * delta
			else:
				top_label.set_visible_characters(top_label.get_visible_characters() + 1)
				count -= 1
			auto_advance_timer = 0.0  # Reset if it's still typing
		else:
			auto_advance_timer += delta
			if auto_advance_timer > auto_advance_delay and not top_finished:
				changeText()
				auto_advance_timer = 0.0
			if top_finished:
				top_start = false
				bottom_start = true     # Bottom text to begin
				show_meter()
		if top_started:
			changeText()
			top_started = false
	
	if (bottom_start):
		if bottom_label.get_visible_ratio() != 1.0:
			if count < 1:
				count += base_speed * delta
			else:
				bottom_label.set_visible_characters(bottom_label.get_visible_characters() + 1)
				count -= 1
			auto_advance_timer = 0.0  # Reset if it's still typing
		else:
			auto_advance_timer += delta
			if auto_advance_timer > auto_advance_delay and not bottom_finished:
				changeText()
				auto_advance_timer = 0.0
			if bottom_finished:
				bottom_start = false
				dialogue_end.emit()
		if bottom_started:
			changeText()
			bottom_started = false

func changeText():
	if top_text.size() > 0:
		top_label.set_visible_ratio(0.0)
		top_label.text = top_text.pop_front()
	else: 
		top_finished = true
		
	if bottom_text.size() > 0:
		bottom_label.set_visible_ratio(0.0)
		bottom_label.text = bottom_text.pop_front()
	else: 
		await get_tree().create_timer(0.5).timeout
		bottom_finished = true

func show_meter():
	if !win:
		$Meter.show()

func _on_dialogue_end():
	if !win:
		input_allowed = true

func _on_win():
	if win_triggered:
		return  # Prevent running this again
	win_triggered = true
	input_allowed = false
	win = true
	top_label.set_visible_characters(0)
	top_label.text = "Well done"
	top_label.set_visible_ratio(0.0)
	top_start = true
	top_started = true
	$Instructions/Bottom.hide()
	$Meter.hide()
	await get_tree().create_timer(2.0).timeout
	$VideoStreamPlayer.stream = launch
	$VideoStreamPlayer.play()
	$VideoStreamPlayer.loop = false


func _on_video_stream_player_finished() -> void:
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://meteoroid-level/scenes/start_screen.tscn")


func _on_red_area_area_entered(area: Area2D) -> void:
	valid = false


func _on_green_area_area_entered(area: Area2D) -> void:
	valid = true

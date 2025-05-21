extends Node2D

signal isMoving
signal begin

@onready var animation = $AnimationPlayer
@onready var zooming_camera = $ZoomOut/PathFollow2D/ZoomingCamera
@onready var rooms = [$Room1, $Room2, $Room3, $Room4]
@onready var covers = [$Room1Cover, $Room2Cover, $Room3Cover, $Room4Cover]
@onready var active_players = [$Room1/Player, $Room3/Player]
@onready var playing_cameras = [$Room1/Player/Camera2D, $Room3/Player/Camera2D]
@onready var wide_camera = $Room1/Room1Camera
@onready var ani_doors = [$Room1/EnterRoom1Door, $Room1/LeaveRoom1Door, $Room4/LeaveRoom4Door]
@onready var solid_doors = [$Room1/EnterDoor, $Room1/LeaveDoor, $Room3/EnterDoor, $Room3/LeaveDoor]
@onready var leave4_sprite = $Room4/LeaveRoom4/PathFollow2D/Player/PlayerSprite
@onready var leave4_path = $Room4/LeaveRoom4/PathFollow2D
@onready var enter_sprite = $Room1/EnterRoom1/PathFollow2D/Player/PlayerSprite
@onready var leave1_sprite = $Room1/LeaveRoom1/PathFollow2D/Player/PlayerSprite
@onready var people = [$Room1/Kids, $Room1/Lady]
@onready var large_camera = $LargeCamera

var current_room := 0
var is_followingpath := false
var room_states = {"enter": false, "leave": false, "zoom": false}

var sign_off_end := false
var credits_done := false
var final_transition_started := false

var wait_time = 2.1
var volume_change = 5
var volume = -20

func _ready() -> void:
	Audio.volume_db = volume
	Audio.play_music_start(volume)
	covers[3].color = Color(0,0,0,1)
	covers[3].show()
	$SignOff/Camera2D.enabled = false
	wide_camera.enabled = false

	for camera in playing_cameras:
		camera.enabled = false
	for player in active_players:
		player.hide()
	for door in solid_doors:
		door.hide()
	for person in people:
		person.hide()
	for door in ani_doors:
		door.play("open")
	
	leave4_sprite.play("idle_up")
	leave1_sprite.play("idle_up")

	$Room3/SecurityGuard.hide()
	leave1_sprite.hide()
	
	await get_tree().create_timer(wait_time).timeout
	animation.play("room4_cover_fade")
	await get_tree().create_timer(wait_time).timeout
	zoom_out()

func _physics_process(delta: float) -> void:
	if room_states["enter"]:
		_process_enter(current_room)
	elif room_states["leave"]:
		_process_leave(current_room)
	elif room_states["zoom"]:
		_process_zoom()

func _process_zoom():
	var pathfollower = $ZoomOut/PathFollow2D
	zooming_camera.enabled = true
	if is_followingpath:
		if pathfollower.progress_ratio < 1:
			pathfollower.progress_ratio += 0.005
			if zooming_camera.zoom > Vector2(0.83, 0.83):
				zooming_camera.zoom -= Vector2(0.03585, 0.03585)
		else:
			end_zoom()

func _process_leave(room_num):
	var pathfollower = rooms[room_num].get_node("LeaveRoom" + str(room_num+1) + "/PathFollow2D")
	if is_followingpath:
		isMoving.emit()
		match room_num:
			3:
				var pathfollower2 = $Room4/MoveChair/PathFollow2D
				if pathfollower.progress_ratio == 0 and pathfollower2.progress_ratio == 0:
					leave4_sprite.play("idle_up")
				elif pathfollower.progress_ratio < 0.0595:
					pathfollower2.progress_ratio += 0.05
				elif pathfollower.progress_ratio < 0.1607:
					leave4_sprite.play("walk_right")
				elif pathfollower.progress_ratio < 0.9:
					leave4_sprite.play("walk_down")
				elif pathfollower.progress_ratio >= 0.9:
					leave4_sprite.play("idle_down")
					leave_end()
				pathfollower.progress_ratio += 0.005
			0:
				if pathfollower.progress_ratio < 0.119:
					leave1_sprite.play("walk_left")
				elif pathfollower.progress_ratio > 0.119 and pathfollower.progress_ratio < 1:
					leave1_sprite.play("walk_down")
				else:
					leave_end()
				pathfollower.progress_ratio += 0.005

func _process_enter(room_num): 
	var pathfollower = rooms[room_num].get_node("EnterRoom" + str(room_num+1) + "/PathFollow2D")
	if is_followingpath:
		isMoving.emit()
		match room_num:
			0:
				if pathfollower.progress_ratio < 0.5654:
					enter_sprite.play("walk_down")
				elif pathfollower.progress_ratio < 1:
					enter_sprite.play("walk_left")
				elif pathfollower.progress_ratio >= 1:
					enter_sprite.play("idle_up")
					enter_end()
				pathfollower.progress_ratio += 0.005

func zoom_out():
	room_states["zoom"] = true
	is_followingpath = true

func end_zoom():
	room_states["zoom"] = false
	is_followingpath = false
	current_room = 3
	await get_tree().create_timer(wait_time).timeout
	start_leave()

func start_leave():
	room_states["leave"] = true
	is_followingpath = true

func leave_end():
	room_states["leave"] = false
	is_followingpath = false
	covers[current_room].color = Color(0,0,0,0)
	covers[current_room].show()
	animation.play("room" + str(current_room+1) + "_cover")
	await get_tree().create_timer(wait_time).timeout
	if current_room == 0:
		check_end_conditions()
	elif current_room == 3:
		enter_room(0)

func enter_room(room_num):
	current_room = room_num
	covers[room_num].color = Color(0,0,0,1)
	covers[room_num].show()
	zooming_camera.enabled = false
	wide_camera.enabled = true
	await get_tree().create_timer(wait_time).timeout
	animation.play("room" + str(room_num+1) + "_cover_fade")
	room_states["enter"] = true
	is_followingpath = true

func enter_end():
	room_states["enter"] = false
	is_followingpath = false
	covers[current_room].color = Color(0,0,0,0)
	covers[current_room].show()
	await get_tree().create_timer(wait_time).timeout
	animation.play("room" + str(current_room+1) + "_cover")
	await get_tree().create_timer(wait_time).timeout
	if current_room == 0:
		sign_off()

func sign_off():
	enter_sprite.hide()
	leave1_sprite.show()
	wide_camera.enabled = false
	$SignOff/Camera2D.enabled = true
	begin.emit()

# Called by signal
func _on_sign_off_sign_off_done() -> void:
	sign_off_end = true
	await get_tree().create_timer(wait_time).timeout
	wide_camera.enabled = true
	$SignOff/Camera2D.enabled = false
	animation.play("room" + str(current_room+1) + "_cover_fade")
	await get_tree().create_timer(wait_time).timeout
	start_leave()
	check_end_conditions()

# Called by signal
func _on_credits_done() -> void:
	credits_done = true
	check_end_conditions()

func check_end_conditions():
	if sign_off_end and credits_done and not final_transition_started:
		final_transition_started = true
		do_final_transition()

func do_final_transition():
	Audio.volume_db -= volume_change
	await get_tree().create_timer(wait_time).timeout
	Audio.volume_db -= volume_change
	get_tree().change_scene_to_file("res://start-menu/start_menu.tscn")

extends Node2D

signal isMoving

@onready var animation = $AnimationPlayer
@onready var zooming_camera = $ZoomIn/PathFollow2D/ZoomingCamera
@onready var rooms = [
	$Room1, $Room2, $Room3, $Room4
]
@onready var covers = [
	$Room1Cover, $Room2Cover, $Room3Cover, $Room4Cover
]
@onready var wide_cameras = [
	$Room1/Room1Camera,
	$Room2/Room2Camera,
	$Room3/Room3Camera,
	$Room4/Room4Camera
]
@onready var active_players = [
	$Room1/Player,
	$Room2/Player,
	$Room3/Player,
]
@onready var playing_cameras = [
	$Room1/Player/Camera2D,
	$Room2/Player/Camera2D,
	$Room3/Player/Camera2D,
]
@onready var enter_ani_doors = [
	$Room1/EnterRoom1Door,
	$Room2/EnterRoom2Door,
	$Room3/EnterRoom3Door,
]
@onready var leave_ani_doors = [
	$Room1/LeaveRoom1Door,
	$Room2/LeaveRoom2Door,
	$Room3/LeaveRoom3Door,
]
@onready var enter_solid_doors = [
	$Room1/EnterDoor,
	$Room2/EnterDoor,
	$Room3/EnterDoor,
]
@onready var leave_solid_doors = [
	$Room1/LeaveDoor,
	$Room2/LeaveDoor,
	$Room3/LeaveDoor,
]
@onready var enter_players = [
	$Room1/EnterRoom1/PathFollow2D/Player,
	$Room2/EnterRoom2/PathFollow2D/Player,
	$Room3/EnterRoom3/PathFollow2D/Player,
	$Room4/EnterRoom4/PathFollow2D/Player
]
@onready var enter_sprites = [
	$Room1/EnterRoom1/PathFollow2D/Player/PlayerSprite,
	$Room2/EnterRoom2/PathFollow2D/Player/PlayerSprite,
	$Room3/EnterRoom3/PathFollow2D/Player/PlayerSprite,
	$Room4/EnterRoom4/PathFollow2D/Player/PlayerSprite
]
@onready var leave_players = [
	$Room1/LeaveRoom1/PathFollow2D/Player,
	$Room2/LeaveRoom2/PathFollow2D/Player,
	$Room3/LeaveRoom3/PathFollow2D/Player
]
@onready var leave_sprites = [
	$Room1/LeaveRoom1/PathFollow2D/Player/PlayerSprite,
	$Room2/LeaveRoom2/PathFollow2D/Player/PlayerSprite,
	$Room3/LeaveRoom3/PathFollow2D/Player/PlayerSprite
]

var current_room := 0
var is_followingpath := false
var room_states = {
	"enter": false,
	"leave": false,
	"zoom": false
}

var open := false

var starting_room = 0

func _ready() -> void:
	zooming_camera.enabled = false
	for i in range(rooms.size()):
		_reset_room(i)
	enter_room(starting_room)

func _reset_room(room_num):
	rooms[room_num].hide()
	covers[room_num].hide()
	wide_cameras[room_num].enabled = false
	enter_players[room_num].movable = false
	
	if room_num < 3:
		playing_cameras[room_num].enabled = false
		active_players[room_num].hide()
		active_players[room_num].movable = false
		_reset_player(room_num,active_players[room_num])
		
		leave_players[room_num].movable = false
		
		enter_solid_doors[room_num].hide()
		enter_solid_doors[room_num].get_node("CollisionShape2D").disabled = true
		leave_solid_doors[room_num].show()
		leave_solid_doors[room_num].get_node("CollisionShape2D").disabled = false
		
		enter_ani_doors[room_num].show()
		leave_ani_doors[room_num].hide()
		
		rooms[room_num].get_node("LeaveRoom" + str(room_num+1)).hide()
		leave_players[room_num].movable = false
	
	rooms[room_num].get_node("EnterRoom" + str(room_num+1)).hide()
	enter_players[room_num].movable = false
	
	if room_num == 2:
		rooms[room_num].get_node("MoveSecurity").hide()
		

func _reset_player(room_num, player):
	match room_num:
		0:
			player.get_node("PlayerSprite").play("idle_up")
			player.get_node("RayCast2D").target_position = Vector2(0, -20)
		1:
			player.get_node("PlayerSprite").play("idle_right")
			player.get_node("RayCast2D").target_position = Vector2(20, 0)
		2:
			player.get_node("PlayerSprite").play("idle_right")
			player.get_node("RayCast2D").target_position = Vector2(20, 0)

func _physics_process(delta: float) -> void:
	if room_states["enter"]:
		_process_enter(current_room)
	elif room_states["leave"]:
		_process_leave(current_room)
	elif room_states["zoom"]:
		_process_zoom()

func _process_enter(room_num):
	var pathfollower = rooms[room_num].get_node("EnterRoom" + str(room_num+1) + "/PathFollow2D")
	if is_followingpath:
		match room_num:
			0:
				if pathfollower.progress_ratio < 0.5233:
					enter_sprites[room_num].play("walk_up")
				if pathfollower.progress_ratio >= 1:
					enter_sprites[room_num].play("idle_up")
					enter_end(room_num)
				pathfollower.progress_ratio += 0.009
			1:
				if pathfollower.progress_ratio < 0.1467:
					enter_sprites[room_num].play("walk_up")
				if pathfollower.progress_ratio >= 0.1467:
					enter_sprites[room_num].play("walk_right")
				if pathfollower.progress_ratio >= 1:
					enter_sprites[room_num].play("idle_right")
					enter_end(room_num)
				pathfollower.progress_ratio += 0.007
			2:
				if pathfollower.progress_ratio < 1:
					enter_sprites[room_num].play("walk_right")
				if pathfollower.progress_ratio >= 1:
					enter_sprites[room_num].play("idle_right")
					enter_end(room_num)
				pathfollower.progress_ratio += 0.01
			3:
				if part1:
					enter_sprites[room_num].play("walk_up")
					if pathfollower.progress_ratio >= 0.7167:
						enter_sprites[room_num].play("idle_left")
						end_part1()
					pathfollower.progress_ratio += 0.008
				if part2: 
					pathfollower = $Room4/MoveChair/PathFollow2D
					if pathfollower.progress_ratio >= 1:
						end_part2()
					pathfollower.progress_ratio += 0.05
				if part3:
					var pathfollower2 = $Room4/MoveChair/PathFollow2D
					if pathfollower.progress_ratio > 0.7167:
						enter_sprites[room_num].play("walk_left")
					if pathfollower.progress_ratio > 0.9067:
						pathfollower2.progress_ratio -= 0.05
						enter_sprites[room_num].play("walk_up")
					if pathfollower.progress_ratio >= 1 && pathfollower2.progress_ratio == 0:
						enter_sprites[room_num].play("idle_up")
						end_part3()
					pathfollower.progress_ratio += 0.005

var part1 = true
var part2 = false
var part3 = false

func end_part1():
	part1 = false
	await get_tree().create_timer(1.0).timeout
	part2 = true
	
func end_part2():
	part2 = false
	await get_tree().create_timer(1.0).timeout
	part3 = true

func end_part3():
	part3 = false
	await get_tree().create_timer(1.0).timeout
	enter_end(current_room)

func enter_end(room_num):
	room_states["enter"] = false
	is_followingpath = false
	if room_num < 3:
		enter_ani_doors[room_num].play("close")
		$Audio/sfx_doors.play()
		await get_tree().create_timer(1.0).timeout
		fade(room_num, false)
		await get_tree().create_timer(1.0).timeout
		enter_ani_doors[room_num].hide()
		enter_solid_doors[room_num].show()
		enter_solid_doors[room_num].get_node("CollisionShape2D").disabled = false
		enter_players[room_num].hide()
		rooms[room_num].get_node("EnterRoom" + str(room_num+1)).hide()
		play_room(room_num)
	elif room_num == 3:
		start_zoom()

func _process_leave(room_num):
	var pathfollower = rooms[room_num].get_node("LeaveRoom" + str(room_num+1) + "/PathFollow2D")
	if is_followingpath:
		match room_num:
			0: 
				if pathfollower.progress_ratio < 0.3929:
					leave_sprites[room_num].play("walk_right")
				if pathfollower.progress_ratio >= 0.3929:
					leave_sprites[room_num].play("walk_up")
				if pathfollower.progress_ratio >= 1:
					leave_sprites[room_num].play("idle_up")
					leave_end(room_num)
				pathfollower.progress_ratio += 0.005
			1:
				if pathfollower.progress_ratio < 0.29:
					leave_sprites[room_num].play("walk_down")
				if pathfollower.progress_ratio >= 0.29:
					leave_sprites[room_num].play("walk_right")
				if pathfollower.progress_ratio >= 1:
					leave_sprites[room_num].play("idle_right")
					leave_end(room_num)
				pathfollower.progress_ratio += 0.005
			2:
				var pathfollower2 = rooms[room_num].get_node("MoveSecurity/PathFollow2D")
				if partA:
					leave_sprites[room_num].play("idle_up")
					rooms[room_num].get_node("SecurityGuard").hide()
					rooms[room_num].get_node("SecurityGuard/CollisionShape2D").disabled = true
					rooms[room_num].get_node("MoveSecurity").show()
					if pathfollower2.progress_ratio < 1:
						$Room3/MoveSecurity/PathFollow2D/AnimatedSprite2D.play("walk")
					if pathfollower2.progress_ratio >= 1:
						$Room3/MoveSecurity/PathFollow2D/AnimatedSprite2D.play("idle")
						end_partA()
					pathfollower2.progress_ratio += 0.05
				if partB:
					if pathfollower.progress_ratio < 1:
						leave_sprites[room_num].play("walk_up")
					if pathfollower.progress_ratio >= 1:
						leave_sprites[room_num].play("idle_up")
						end_partB()
					pathfollower.progress_ratio += 0.007

func end_partA():
	partA = false
	await get_tree().create_timer(1.0).timeout
	Audio.play_music_minigame(-15)
	partB = true

func end_partB():
	partB = false
	await get_tree().create_timer(1.0).timeout
	leave_end(current_room)

var partA = true
var partB = false

func leave_end(room_num):
	room_states["leave"] = false
	is_followingpath = false
	if room_num < 3:
		leave_ani_doors[room_num].play("close")
		$Audio/sfx_doors.play()
		fade(room_num,false)
		await get_tree().create_timer(1.0).timeout
		leave_players[room_num].hide()
		rooms[room_num].get_node("LeaveRoom" + str(current_room+1)).hide()
		await get_tree().create_timer(1.0).timeout
		switch_room(room_num + 1)

func _process_zoom():
	var pathfollower = $ZoomIn/PathFollow2D
	wide_cameras[current_room].enabled = false
	zooming_camera.enabled = true
	if is_followingpath:
		if pathfollower.progress_ratio < 1:
			pathfollower.progress_ratio += 0.005
			if zooming_camera.zoom < Vector2(8, 8):
				zooming_camera.zoom += Vector2(0.03585, 0.03585)
		else:
			end_zoom()

func enter_room(room_num):
	rooms[room_num].show()
	wide_cameras[room_num].enabled = true
	covers[room_num].color = Color(0,0,0,1)
	covers[room_num].show()
	
	rooms[room_num].get_node("EnterRoom" + str(room_num+1)).show()
	
	fade(room_num, true)
	
	if room_num < 3:
		enter_ani_doors[room_num].play("open")
		$Audio/sfx_doors.play()
	
	room_states["enter"] = true
	is_followingpath = true
	isMoving.emit()
	current_room = room_num

func fade(room_num, uncover):
	if uncover:
		match room_num:
			0: 
				animation.play("room1_cover_fade")
			1: 
				animation.play("room2_cover_fade")
			2: 
				animation.play("room3_cover_fade")
			3: 
				animation.play("room4_cover_fade")
	else:
		match room_num:
			0: 
				animation.play("room1_cover")
			1: 
				animation.play("room2_cover")
			2: 
				animation.play("room3_cover")
			3: 
				animation.play("room4_cover")

func play_room(room_num):
	await get_tree().create_timer(0.5).timeout
	wide_cameras[room_num].enabled = false
	if room_num < 3:
		playing_cameras[room_num].enabled = true
	active_players[room_num].show()
	await get_tree().create_timer(1.0).timeout
	fade(room_num, true)
	await get_tree().create_timer(1.0).timeout
	active_players[room_num].movable = true
	covers[room_num].hide()
	Globals.get_node("Hint").show()
	
func _on_win():
	Globals.get_node("Hint").hide()
	Globals.get_node("EscapeRoomHints").hide()
	covers[current_room].color = Color(0,0,0,0)
	covers[current_room].show()
	fade(current_room,false)
	await get_tree().create_timer(1.0).timeout
	leave_ani_doors[current_room].show()
	leave_solid_doors[current_room].hide()
	leave_solid_doors[current_room].get_node("CollisionShape2D").disabled = true
	active_players[current_room].hide()
	active_players[current_room].movable = false
	active_players[current_room].moving = false
	rooms[current_room].interactable = false
	rooms[current_room].get_node("Player/Camera2D/QuestionPopUp").hide()
	start_leave()

func switch_room(next_index):
	if next_index < rooms.size():
		covers[next_index].show()
		rooms[next_index].show()
		covers[current_room].hide()
		wide_cameras[current_room].enabled = false
		wide_cameras[next_index].enabled = true
		current_room = next_index
		await get_tree().create_timer(0.5).timeout
		enter_room(next_index)

func start_leave():
	playing_cameras[current_room].enabled = false
	wide_cameras[current_room].enabled = true
	fade(current_room,true)
	rooms[current_room].get_node("LeaveRoom" + str(current_room+1)).show()
	leave_ani_doors[current_room].play("open")
	$Audio/sfx_doors.play()
	room_states["leave"] = true
	is_followingpath = true
	isMoving.emit()

func start_zoom():
	room_states["zoom"] = true
	is_followingpath = true

func end_zoom():
	room_states["zoom"] = false
	is_followingpath = false
	fade(current_room,false)
	await get_tree().create_timer(1.0).timeout
	fade(current_room,true)
	Globals.get_node("Hint").show()
	get_tree().change_scene_to_file("res://launch/scenes/launch.tscn")

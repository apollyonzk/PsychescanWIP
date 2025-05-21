extends AudioStreamPlayer

const start_music = preload("res://audio/start.ogg")
const dialogue = preload("res://audio/dialogue.mp3")
const minigame_music = preload("res://audio/minigames.ogg")
const background_room_music = preload("res://audio/rooms.ogg")
const door = preload("res://audio/doors.mp3")
const open_popup = preload("res://audio/open.mp3")
const close_popup = preload("res://audio/tone.wav")
const steps = preload("res://audio/steps.mp3")
const correct = preload("res://audio/correct.mp3")
const incorrect = preload("res://audio/incorrect.wav")

func _play_music(music: AudioStream, volume):
	if stream == music:
		return
	stream = music
	volume_db = volume
	play()
	
func _play_sound(music: AudioStream, volume):
	if stream == music:
		return
	stream = music
	volume_db = volume
	play()

func play_music_start(volume):
	_play_music(start_music, volume)

func play_music_minigame(volume):
	_play_music(minigame_music, volume)

func play_music_rooms(volume):
	_play_music(background_room_music, volume)

func play_door(volume):
	_play_sound(door, volume)

func play_open(volume):
	_play_sound(open_popup, volume)
	
func play_close(volume):
	_play_sound(close_popup, volume)
	
func play_steps(volume):
	_play_sound(steps, volume)
	
func play_correct(volume):
	_play_sound(correct, volume)
	
func play_incorrect(volume):
	_play_sound(incorrect, volume)	

func play_dialogue(volume):
	_play_sound(dialogue, volume)	







func _on_mute_toggled(toggled_on: bool) -> void:
	var master_bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(master_bus_index, toggled_on)
	$Mute.focus_mode = false

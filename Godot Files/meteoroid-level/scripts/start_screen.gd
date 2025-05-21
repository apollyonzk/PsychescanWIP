# script for start screen dialogue

extends Control

var text = [
	"Psyche Course Correction Simulator
	
	
	
	This software will allow you 
	
	to plan out the shuttle's course
	
	to avoid obstacles on its 
	
	way to the asteroid."
	
]
@onready var message: Label = $Message
@onready var start_button: Button = $Message/StartButton
@onready var typing_sound: AudioStreamPlayer2D = $TypingSound

const base_speed := 40
var started := true
var finished := false
var count := 0.0
var covered = true
var start = false

func _ready() -> void:
	start_button.hide() # hides button till done
	await get_tree().create_timer(1.0).timeout
	start = true

# function to type out message to player
func _process(delta: float) -> void:
	if (start):
		if(message.get_visible_ratio() != 1.0):
			if(count < 1):
				count += base_speed*delta
			else:
				message.set_visible_characters(message.get_visible_characters()+1)
				if (message.get_visible_characters() % 2 == 0):
					typing_sound.play()
				count -= 1
		else:
			if text.is_empty() && !finished:
				finished = true
			else:
				if (covered):
					covered = false
		if(started):
			changeText()
			started = false
		if (finished):
			covered = false
			start_button.show()

func changeText():
	if text.size() > 0:
		message.set_visible_ratio(0.0)
		message.text = text.pop_front()
	else: 
		finished = true

# can skip dialogue with spacebar
func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		covered = true
		if(message.get_visible_ratio() == 1.0):
			changeText()
		else:
			message.set_visible_ratio(1.0)
	if event.is_action_pressed("interact"):
		while text.size() != 0:
			covered = true
			if(message.get_visible_ratio() == 1.0):
				changeText()
			else:
				message.set_visible_ratio(1.0)

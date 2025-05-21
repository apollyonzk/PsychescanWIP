extends Node2D

const scrollSpeed = 100

@export var text: PackedScene
var texts = null
var blocks = []
var startPos
var textBox = false
var state = 0
var nextLeter = 0
var label
var animationPlayer
var psychePlayer
var playing = false
var psychePlaying = false
var correctSound
var correct
var speedup = false
var speedupMult = 3
const lineSpeed = 100


var rightTextBlocks = [
	"Hit [Enter] or [Space] to continue through the dialogue.",
	"The Psyche satellite will send out words.",
	"These words act as the information sent back from psyche to be analyzed.",
	"To complete this section, type the words to analyze what they are.",
	"The satellite will continue to send out information until all information has been received.",
	"Tip: Some information are multiple words and require you to hit space between words.",
	"Tip: If the words are moving too slow for you, you can hold the Left arrow key to speed them up."
]


#[name, delay, text
var textBlocks = [
	["Mission", "For the first time ever, we are exploring a world made not of rock or ice, but of metal."],
	["Psyche", "A unique metal asteroid which provides a window into the formation of planetary cores."],
	["Instruments","The instruments consist of a magnetometer, a multispectral imager, and a gamma ray and neutron spectrometer."],
	["Multispectral Imager", "The Multispectral Imager provides high-resolution images using filters to discriminate between Psyche’s metallic and silicate constituents."],
	["Spectrometer", "The Gamma-Ray and Neutron Spectrometer will detect, measure, and map Psyche’s elemental composition."],
	["Magnetometer", "The Magnetometer is designed to detect and measure the remanent magnetic field of the asteroid."],
	["Communication", "The Psyche mission will test a new laser communication technology that encodes data in photons to communicate between a probe and Earth. This allows for more data in less time."],
	["Radio", "The Psyche mission will use the X-band radio telecommunications system to measure Psyche’s gravity field to high precision."],
	["Phase B", "Science and engineering teams on the mission designed the spacecraft and the instruments that will be used to analyze the asteroid."],
	["Phase C", "Science and engineering teams begin to build their instruments."],
	["Phase D", "This phase involves the assembly and launch of the spacecraft."],
	["Phase E", "This is the phase which involves the travel to the asteroid along with the data collection of the asteroid. All the computer screen minigames all exist in this phase."],
	["Gravity Assist", "The Mars Gravity Assist is a slingshot maneuver saves propellant, time and expense. It does this by entering and leaving the gravitational field of Mars."]
]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	startPos = $Node2D.position
	label = $Node2D2/Label
	animationPlayer = $Node2D2/satellitePlayer
	psychePlayer = $Node2D2/psychePlayer
	correctSound = $Node2D2/CorrectSound
	correct = $Node2D2/Correct
	label.text = rightTextBlocks.pop_front()
	label.visible_ratio = 0
	return
	#texts = text.instantiate(0)
	#add_child(texts)
	#texts.setPos(startPos)
	#texts.setText("banana")
	#blocks.append(texts)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not psychePlaying:
		psychePlayer.play("PsycheSpin")
		psychePlaying = true
	if state == 0:
		if not playing:
			animationPlayer.play("Spin")
			playing = true
		cycleText(delta)
	elif state == 1:
		if not playing:
			animationPlayer.play("Start Cutscene")
			playing = true
	elif state == 2:
		stateTwo(delta)
	elif state == 3:
		if not playing:
			animationPlayer.play("endingSection")
			playing = true
	elif state == 4:
		changeScene()
		

func stateTwo(delta):
	if textBox:
		return#simply exists as a check
	if blocks.size() == 0 && textBlocks.size() != 0:
		addBlock()
	elif blocks.size() > 0:
		if blocks.back().global_position.x + blocks.back().rightPoint() + 50 < startPos.x:
			addBlock()
		for i in blocks:
			i.move((-lineSpeed*delta*speedupMult) if speedup else (-lineSpeed*delta))
			i.checkFail(delta)
			if i.global_position.x  < -i.rightPoint():
				if not i.completed():
					textBlocks.append(i.getInfo())
				blocks.erase(i)
				i.free()
	elif textBlocks.size() == 0:
		state = 3
		
	
func changeScene():
	get_tree().change_scene_to_file("res://credits/scenes/leave.tscn")
#adds a block to the blocks list
func addBlock():
	if textBlocks.size() == 0:
		return
	var popValues = textBlocks.pop_front()
	var newText = text.instantiate(0)
	$Node2D3/Node2D.add_child(newText)
	#newText.setPos(startPos)
	newText.setText(popValues[0])
	newText.setInformation(popValues)
	blocks.append(newText)

func _unhandled_input(event):
	if state == 0:
		if event.is_action_pressed("ui_accept"):
			if label.visible_ratio < 1:
				label.visible_ratio = 1
				return
			if rightTextBlocks.size() > 0:
				label.visible_ratio = 0
				nextLeter = 0
				label.text = rightTextBlocks.pop_front()
			else:
				label.visible_ratio = 0
				correctSound.play()
				correct.visible = true
				state=1
	elif state == 2:
		if textBox:
			return
		
		if Input.is_key_pressed(KEY_LEFT) and !event.is_echo():
			speedup = true
		elif not Input.is_key_pressed(KEY_LEFT) and !event.is_echo():
			speedup = false
		if event is InputEventKey and not event.is_pressed():
			for i in blocks:
				i.typeChecking(event)
				if i.checkDone():
					correct.visible = true
					correctSound.play()
					$Control/Label.text = i.getInfo()[1]
					$Control.visible = true
					textBox = true


func _on_button_button_up() -> void:
	correct.visible = false
	$Control.visible = false
	textBox = false

func cycleText(delta):
	if label.visible_ratio < 1:
		nextLeter += delta*30
		label.visible_characters = nextLeter
		

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Spin":
		playing = false
	if anim_name == "Start Cutscene":
		state = 2
		correct.visible = false
		playing = false
	if anim_name == "endingSection":
		state = 4
		playing = false


func _on_psyche_player_animation_finished(anim_name: StringName) -> void:
	psychePlaying = false #resets the ability to loop psyche spinning

extends Node2D


signal popup_open
signal popup_close

signal win

@onready var player = $Player
@onready var page_text = $Player/Camera2D/PageSprite/Message
@onready var page = $Player/Camera2D/PageSprite
@onready var question_popup = $Player/Camera2D/QuestionPopUp
@onready var question = $Player/Camera2D/QuestionPopUp/QuestionContainer
@onready var question_label = $Player/Camera2D/QuestionPopUp/QuestionContainer/QuestionLabel
@onready var validation = $Player/Camera2D/QuestionPopUp/ValidationContainer
@onready var valid_msg = $Player/Camera2D/QuestionPopUp/ValidationContainer/Message
@onready var cabinet_popup = $Player/Camera2D/CabinetDescription
@onready var cabinet_msg = $Player/Camera2D/CabinetDescription/Container/Message
@onready var sign_popup = $Player/Camera2D/SignPopUp

@onready var popups = [
	question_popup,
	cabinet_popup,
	sign_popup
]

var interactable = false
var isOpen = false
var correct
var rng = RandomNumberGenerator.new()
var questions_dict = {
	0: ["Which of the following is an instrument on the spacecraft?", 
		"A defibrillator", 
		"An anemometer", 
		"A magnetometer"],
	1: ["Psyche is...", 
		"possibly part of a planetesimal core", 
		"mostly made of rock and ice", 
		"not going to collect data"],
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Hide popups
	for popup in popups:
		popup.hide()
	
	var question_number = rng.randi_range(0,1)
	question_label.text = questions_dict[question_number][0]
	question.get_node("Options/Option1").text = questions_dict[question_number][1]
	question.get_node("Options/Option2").text = questions_dict[question_number][2]
	question.get_node("Options/Option3").text = questions_dict[question_number][3]
	
	if (question_number == 0):
		correct = 3
	else:
		correct = 1

	cabinet_msg.text = "It's a cabinet full of documents about the Psyche mission. One document says that Psyche may be the core of a planetesimal. Planetesimals crash into each other and create planets."

	$SecurityGuard/Sprite2D.play("default")
	
	player.movable = false
	
	Globals.hint_open.connect(_on_hint_open)
	Globals.hint_close.connect(_on_hint_close)

func _on_hint_open():
	interactable = false
	player.movable = false
	
func _on_hint_close():
	interactable = true
	player.movable = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (interactable == true):
		var collidingNode = $Player/RayCast2D.get_collider()
		if collidingNode == $SecurityGuard:
			handle_popup(question_popup)
		elif collidingNode == $Cabinet:
			handle_popup(cabinet_popup)
		elif collidingNode == $Sign:
			handle_popup(sign_popup)

func handle_popup(popup_node: Node) -> void:
	if Input.is_action_just_pressed("interact"):
		Globals.get_node("EscapeRoomHints").hide()
		Globals.get_node("Hint").hide()
		match popup_node:
			question_popup: 
				question.show()
				validation.hide()
		popup_node.show()
		if !isOpen:
			$Audio/sfx_open.play()
		isOpen = true
		$Player/PressE.hide()
		popup_open.emit()
	elif Input.is_action_just_pressed("ui_cancel"):
		Globals.get_node("Hint").show()
		popup_node.hide()
		if isOpen:
			$Audio/sfx_close.play()
		isOpen = false
		$Player/PressE.show()
		popup_close.emit()

func correct_answer() -> void:
	$Audio/sfx_correct.play()
	valid_msg.text = "Correct!"
	question.hide()
	validation.show()
	interactable = false
	await get_tree().create_timer(2.0).timeout
	win.emit()
	
func wrong_answer() -> void:
	$Audio/sfx_close.stop()
	$Audio/sfx_close.play()
	valid_msg.text = "Sorry, that is incorrect. Try looking around the room for more hints!"
	question.hide()
	validation.show()
	
func _on_question_option_1() -> void:
	if (correct == 1):
		correct_answer()
	else:
		wrong_answer()

func _on_question_option_2() -> void:
	if (correct == 2):
		correct_answer()
	else:
		wrong_answer()

func _on_question_option_3() -> void:
	if (correct == 3):
		correct_answer()
	else:
		wrong_answer()

func _on_player_interact() -> void:
	interactable = true
	if ($Player/RayCast2D.is_colliding()):
		$Player/PressE.show()

func _on_player_no_interact() -> void:
	interactable = false
	$Player/PressE.hide()

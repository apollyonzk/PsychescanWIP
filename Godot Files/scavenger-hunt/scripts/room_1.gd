extends Node2D

# Signals used to communicate popup and win events
signal popup_open
signal popup_close
signal win

# References to nodes in the scene, most to handle changing popup messages
@onready var player = $Player
@onready var question_area= $QuestionArea
@onready var question_popup = $Player/Camera2D/QuestionPopUp
@onready var question = $Player/Camera2D/QuestionPopUp/QuestionContainer
@onready var question_label = $Player/Camera2D/QuestionPopUp/QuestionContainer/QuestionLabel
@onready var validation = $Player/Camera2D/QuestionPopUp/ValidationContainer
@onready var valid_msg = $Player/Camera2D/QuestionPopUp/ValidationContainer/Message
@onready var notebook_area = $NotebookArea
@onready var page_text = $Player/Camera2D/PageSprite/Message
@onready var page = $Player/Camera2D/PageSprite
@onready var picture_area = $PictureArea
@onready var picture = $Player/Camera2D/PicturePopUp
@onready var picture_msg = $Player/Camera2D/PicturePopUp/Container/Message
@onready var chair_area = $Chairs/Area2D
@onready var chair = $Player/Camera2D/ChairPopUp
@onready var chair_msg = $Player/Camera2D/ChairPopUp/Container/Message
@onready var coffee_table_area = $CoffeeTable/Area2D
@onready var coffee_table = $Player/Camera2D/CoffeeTablePopUp
@onready var coffee_table_msg = $Player/Camera2D/CoffeeTablePopUp/Container/Message
@onready var lady_area = $Lady
@onready var lady = $Player/Camera2D/LadyDescription
@onready var lady_msg = $Player/Camera2D/LadyDescription/Container/Message
@onready var kids_area = $Kids
@onready var kids = $Player/Camera2D/KidPopUp
@onready var kids_msg = $Player/Camera2D/KidPopUp/Container/Message

@onready var popups = [
	page,
	picture,
	chair,
	coffee_table,
	lady,
	kids,
	question_popup
]

# For tracking number of chair popups open
@onready var num_opened := 0

var isOpen := false                    # Whether a popup is open
var interactable := false              # Whether item is interactable (receiving from player)
var rng = RandomNumberGenerator.new()  # For choosing random question
var correct                            # Correct answer index for question

# Different question choices
var questions_dict = {
	0: ["When did the Psyche spacecraft launch?", 
		"Friday, October 13, 2023", 
		"Friday, October 07, 2023", 
		"Thursday, October 12, 2023"],
	1: ["When will the Psyche spacecraft start orbiting the asteroid?", 
		"August 2028", 
		"April 2029", 
		"August 2029"],
	2: ["Which rocket launched NASA's Psyche mission?", 
		"NASA's Saturn V", 
		"SpaceX Falcon Heavy",
		"SpaceX Toucan Light"],
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Hide all popups
	for popup in popups:
		popup.hide()
	
	# Select a random question
	var question_number = rng.randi_range(0,2)
	
	# Set the question and answers in UI
	question_label.text = questions_dict[question_number][0]
	question.get_node("Options/Option1").text = questions_dict[question_number][1]
	question.get_node("Options/Option2").text = questions_dict[question_number][2]
	question.get_node("Options/Option3").text = questions_dict[question_number][3]
	
	# Set the notebook page message
	if question_number == 0:
		correct = 1
		page_text.text = "It's someone's work journal...\n\nOctober 12, 2023\n\nToday I learned that Psyche takes off tomorrow... My boss wasn't very happy... Oops!"
	elif question_number == 1:
		correct = 3
		page_text.text = "It's someone's work journal...\n\nAugust 1, 2023\n\nI can't believe I have to wait so long for the spacecraft to start orbiting Psyche. I wish it was 6 years in the future already!"
	elif question_number == 2:
		correct = 2
		page_text.text = "It's someone's work journal...\n\nOctober 13, 2023\n\nI've been calling the rocket Toucan Light since the beginning. My friend told me he thought I was joking this whole time. I didn't realize how wrong I was until today... Oops!"

	# Set popup messages
	picture_msg.text = "It's a picture of the preliminary design of the instruments and spacecraft. The description says it will reach Psyche in August 2029."
	chair_msg.text = "It's just a chair..."
	coffee_table_msg.text = "It's a collection of articles about Psyche. Hmm there's something underneath them... Oh! It's a sticky note that says\n16-19-25-3-8-5\nHmmm... I wonder what that means."
	lady_msg.text = "\"It's bring your kids to work day today, but they won't stop playing. I don't blame them, though.\""
	kids_msg.text = "\"We're not allowed to talk to strangers.\""
	
	# Play NPC animations
	$Receptionist/ReceptionistSprite.play("default")
	$Kids/Boy.play("default")
	$Kids/Girl.play("default")
	$Lady/AnimatedSprite2D.play("default")
	
	# Ensure player is immovable to start
	player.movable = false

	# Connect signals from Global for when the hint is open or closed
	Globals.hint_open.connect(_on_hint_open)
	Globals.hint_close.connect(_on_hint_close)

# Make sure player is immovable and not interactable when hint is open
func _on_hint_open():
	interactable = false
	player.movable = false

# Make sure player is able to move and interact when hint is closed 
func _on_hint_close():
	interactable = true
	player.movable = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# If an item is interactable, handle appropriately
	if interactable:
		var collidingNode = $Player/RayCast2D.get_collider()
		if collidingNode == question_area:
			handle_popup(question_popup)
		elif collidingNode == notebook_area:
			handle_popup(page)
		elif collidingNode == picture_area:
			handle_popup(picture)
		elif collidingNode == chair_area:
			handle_popup(chair)
		elif collidingNode == coffee_table_area:
			handle_popup(coffee_table)
		elif collidingNode == lady_area:
			handle_popup(lady)
		elif collidingNode == kids_area:
			handle_popup(kids)

# Open or close popup accordingly
func handle_popup(popup_node: Node) -> void:
	if Input.is_action_just_pressed("interact"):
		Globals.get_node("EscapeRoomHints").hide()    # Hide the hint button and hint to ensure no conflicts
		Globals.get_node("Hint").hide()
		match popup_node:                             
			question_popup:                           # If question, show the question and hide the validation to ensure validation isn't shown when first opened
				question.show()
				validation.hide()
			chair:                                    # If chair, show the message depending on how many times player has opened
				num_opened += 1
				if num_opened % 2 == 0:
					chair_msg.text = "This is... just a chair"
				else:
					chair_msg.text = "It's just a chair..."
		popup_node.show()
		if !isOpen:                                   # If not open, play the open sound
			$Audio/sfx_open.play()
		isOpen = true
		$Player/PressE.hide()
		popup_open.emit()                             # Emit signal
	elif Input.is_action_just_pressed("ui_cancel"):  
		Globals.get_node("Hint").show()               # Show hint button
		popup_node.hide()                             # Hide popup
		if isOpen:                                    # If is open, play close sound
			$Audio/sfx_close.play()
		isOpen = false
		$Player/PressE.show()
		popup_close.emit()                             # Emit signal

# If the correct answer is selected
func correct_answer() -> void:
	_on_player_no_interact()
	$Audio/sfx_correct.play()
	valid_msg.text = "Correct!"
	question.hide()
	validation.show()
	interactable = false
	await get_tree().create_timer(2.0).timeout
	win.emit()

# If wrong answer is selected
func wrong_answer() -> void:
	$Audio/sfx_close.stop()
	$Audio/sfx_close.play()
	valid_msg.text = "Sorry, that is incorrect. Try looking around the room for more hints!"
	question.hide()
	validation.show()

# Make sure each option is declared as correct or incorrect depending on the question
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

# Receiving signals for when an interactable object is/isn't under the player's raycast
func _on_player_interact() -> void:
	interactable = true
	if ($Player/RayCast2D.is_colliding()):
		$Player/PressE.show()

func _on_player_no_interact() -> void:
	interactable = false
	$Player/PressE.hide()

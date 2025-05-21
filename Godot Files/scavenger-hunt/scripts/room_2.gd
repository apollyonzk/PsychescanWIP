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
@onready var papers1 = $Player/Camera2D/Papers1Description
@onready var papers1_msg = $Player/Camera2D/Papers1Description/Container/Message
@onready var papers2 = $Player/Camera2D/Papers2Description
@onready var papers2_msg = $Player/Camera2D/Papers2Description/Container/Message
@onready var shelves = $Player/Camera2D/ShelvesDescription
@onready var shelves_msg = $Player/Camera2D/ShelvesDescription/Container/Message
@onready var computer = $Player/Camera2D/ComputerDescription
@onready var comp_msg = $Player/Camera2D/ComputerDescription/Container/Message
@onready var wifi_area = $WifiArea
@onready var wifi = $Player/Camera2D/WifiPopUp
@onready var wifi_msg = $Player/Camera2D/WifiPopUp/Container/Message
@onready var guy_area = $GuyArea
@onready var guy = $Player/Camera2D/GuyPopUp
@onready var guy_msg = $Player/Camera2D/GuyPopUp/Container/Message

@onready var popups = [
	computer,
	papers2,
	papers1,
	shelves,
	question_popup,
	wifi,
	guy
]

var interactable = false
var isOpen = false
var rng = RandomNumberGenerator.new()
var correct

var start_date = { "year": 2023, "month": 10, "day": 13, "weekday": 5, "hour": 10, "minute": 19, "second": 43, "dst": true }   # 3:19pm UTC, +5 10:19am EDT, +8 7:19am PDT, +6 9:19am EST, +9 6:19am PST                  
var time_zone = Time.get_time_zone_from_system()                                                                               # 5:26pm UTC, +5 12:26am EDT, +8 9:26pm PDT, +6 11:26pm EST, +9 8:26pm PST 
var start_unix_time = Time.get_unix_time_from_datetime_dict(start_date)
var current_datetime = Time.get_datetime_dict_from_system()   # UTC time zone
var current_unix_time = Time.get_unix_time_from_datetime_dict(current_datetime)  # Unix time (seconds) in UTC	
var start_zone
var days
var hours
var minutes

var questions_dict = {
	0: ["To what program did the team submit their proposal and concept study?", 
		"NASA's Space Exploration Program", 
		"NASA's Discovery Program", 
		"NASA and Space Discovery Program"],
	1: ["How long ago did the space craft lauch?", 
		"-", 
		"-", 
		"-"],
	2: ["When did the team submit the initial proposal?", 
		"2013", 
		"2009", 
		"2011"],
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Hide popups
	for popup in popups:
		popup.hide()
	
	# Date calculation and logic
	var start_utc = start_unix_time
	var current_utc = current_unix_time
	if current_datetime.dst == false:                                           # If not daylight savings
		current_utc = current_unix_time - ((time_zone["bias"] - 60) * 60)       # Add 1 hour to UTC bias to get local no DST
	else:
		current_utc = current_unix_time - ((time_zone["bias"]) * 60)            # Add UTC bias to get local

	start_zone = "Eastern Daylight Time"
	start_utc = start_unix_time + (5 * 60 * 60)                                 # Add 5 hours from EDT to convert to UTC

	var elapsed_seconds = current_utc - start_utc

	# Convert to days, hours, minutes
	days = elapsed_seconds / 86400
	hours = (elapsed_seconds % 86400) / 3600
	minutes = ((elapsed_seconds % 3600) / 60)
	
	questions_dict[1][1] = ("%d days" % [days])
	questions_dict[1][2] = ("%d days" % [(days - 4)])
	questions_dict[1][3] = ("%d days" % [(days + 5)])
	
	var question_number = rng.randi_range(0,2)
	question_label.text = questions_dict[question_number][0]
	question.get_node("Options/Option1").text = questions_dict[question_number][1]
	question.get_node("Options/Option2").text = questions_dict[question_number][2]
	question.get_node("Options/Option3").text = questions_dict[question_number][3]
	
	if question_number == 0:
		correct = 2
	elif question_number == 1:
		correct = 1
	elif question_number == 2:
		correct = 3
		
	papers1_msg.text = "It's a 256 page proposal that was selected for the concept study."
	papers2_msg.text = "Wow! It's a 1,000 word concept study submitted for consideration for NASA’s Discovery Program."
	shelves_msg.text = "It's a collection of some of the research the team did. Some of it dates all the way back to 2011 when they submitted the concept study."
	comp_msg.text = "It's the Psyche website. It has a lot of important information"
	wifi_msg.text = "It says:\nWiFi: Super Psyched\nPassword: 16-19-25-3-8-5"
	guy_msg.text = "\"I'm reading about Psyche. You need to get to the control room!\""

	$Scientist/Sprite2D.play("default")
	$GuyArea/Guy.play("default")
	
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
		if collidingNode == $Scientist:
			handle_popup(question_popup)
		elif collidingNode == $Papers1:
			handle_popup(papers1)
		elif collidingNode == $Papers2:
			handle_popup(papers2)
		elif collidingNode == $Shelves:
			handle_popup(shelves)
		elif collidingNode == $ComputerArea:
			handle_popup(computer)
		elif collidingNode == wifi_area:
			handle_popup(wifi)
		elif collidingNode == guy_area:
			handle_popup(guy)

func handle_popup(popup_node: Node) -> void:
	if Input.is_action_just_pressed("interact"):
		Globals.get_node("EscapeRoomHints").hide()
		Globals.get_node("Hint").hide()
		if popup_node == question_popup: 
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

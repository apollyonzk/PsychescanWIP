extends Control

signal option1
signal option2
signal option3

@onready var options := [
	$QuestionContainer/Options/Option1,
	$QuestionContainer/Options/Option2,
	$QuestionContainer/Options/Option3
]

var selected_option := 1
var has_started_selecting := false
var is_answered := false  # NEW: Prevent further input after answer

@onready var highlight_style := preload("res://scavenger-hunt/assets/pop_up/question-hover.tres")
@onready var normal_style := preload("res://scavenger-hunt/assets/pop_up/normal.tres")

func _ready():
	reset_highlight()

	# Connect mouse signals to clear keyboard highlight
	for option in options:
		option.mouse_entered.connect(clear_highlight_due_to_mouse)
		option.pressed.connect(clear_highlight_due_to_mouse)

func _process(delta):
	if not visible or is_answered:
		return

	if Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_up"):
		if not has_started_selecting:
			selected_option = 1
			has_started_selecting = true
		else:
			if Input.is_action_just_pressed("ui_down"):
				selected_option = (selected_option % 3) + 1
			elif Input.is_action_just_pressed("ui_up"):
				selected_option = (selected_option - 2 + 3) % 3 + 1
		highlight_selected_option()

	elif Input.is_action_just_pressed("ui_accept"):
		emit_selected_option()

	elif Input.is_action_just_pressed("1"):
		selected_option = 1
		emit_selected_option()
	elif Input.is_action_just_pressed("2"):
		selected_option = 2
		emit_selected_option()
	elif Input.is_action_just_pressed("3"):
		selected_option = 3
		emit_selected_option()

func emit_selected_option():
	if is_answered:
		return

	has_started_selecting = true
	highlight_selected_option()
	is_answered = true  # NEW: Lock future input

	match selected_option:
		1: option1.emit()
		2: option2.emit()
		3: option3.emit()

func highlight_selected_option():
	if is_answered:
		return  # Prevent highlight change if already answered

	for i in range(3):
		options[i].add_theme_stylebox_override("normal", normal_style)
	options[selected_option - 1].add_theme_stylebox_override("normal", highlight_style)

func reset_highlight():
	selected_option = 1
	has_started_selecting = false
	is_answered = false  # NEW: Reset lock
	for i in range(3):
		options[i].add_theme_stylebox_override("normal", normal_style)

func clear_highlight_due_to_mouse():
	if is_answered:
		return  # Do not reset highlight if already answered

	has_started_selecting = false
	reset_highlight()

func _on_room_1_popup_close() -> void:
	reset_highlight()

func _on_room_2_popup_close() -> void:
	reset_highlight()

func _on_room_3_popup_close() -> void:
	reset_highlight()

func _on_option_1_pressed() -> void:
	if is_answered:
		return
	is_answered = true  # NEW: Lock input
	option1.emit()

func _on_option_2_pressed() -> void:
	if is_answered:
		return
	is_answered = true  # NEW: Lock input
	option2.emit()

func _on_option_3_pressed() -> void:
	if is_answered:
		return
	is_answered = true  # NEW: Lock input
	option3.emit()

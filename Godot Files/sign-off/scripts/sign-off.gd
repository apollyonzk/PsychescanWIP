extends Node2D

signal sign_off_done

@onready var animation = $AnimationPlayer

const section_time := 2.0
const base_speed := 1000
const speed_up_multiplier := 10.0

var scroll_speed := base_speed
var speed_up = false

@onready var container = $PageContainer
@onready var submitting_party = $PageContainer/Input/SubmittingParty
@onready var submitting_name = $PageContainer/Input/SubmittingName
@onready var submitting_title = $PageContainer/Input/SubmittingTitle
@onready var date_submitted = $PageContainer/Input/DateSubmitted

@onready var receiving_party = $PageContainer/Input/ReceivingParty
@onready var receiving_name = $PageContainer/Input/ReceivingName
@onready var receiving_title = $PageContainer/Input/ReceivingTitle
@onready var date_received = $PageContainer/Input/DateReceived

var scrollDone = false
var textDone = false
var fadeDone = false
var played = false

var uncovered := false

@onready var date = Time.get_datetime_dict_from_system()

func _on_leave_begin() -> void:
	$Cover.show()
	$Cover.color = Color(0,0,0,1)
	await get_tree().create_timer(1.0).timeout
	animation.play("cover_fade")
	uncovered = true
	
	# Format date
	var month = str(date.month).pad_zeros(2)
	var day = str(date.day).pad_zeros(2)
	var year = str(date.year)
	var formatted_date = "%s/%s/%s" % [month, day, year]
	
	await get_tree().create_timer(3.0).timeout

	# Start typing in sequence
	await type_text(submitting_party, "Kuiper")
	await type_text(submitting_name, "Kuiper")
	await type_text(submitting_title, "Super Psyched Mission Lead")
	await type_text(date_submitted, formatted_date)

	await type_text(receiving_party, "Ms. Mission")
	await type_text(receiving_name, "Ms. Mission")
	await type_text(receiving_title, "Executive Assistant")
	await type_text(date_received, formatted_date)

	textDone = true

func type_text(label_node: Label, text: String, speed: float = 0.05) -> void:
	label_node.text = ""
	for i in text.length():
		label_node.text += text[i]
		await get_tree().create_timer(speed).timeout

func _process(delta: float) -> void:
	if uncovered:
		var scroll_amount = base_speed * delta

		if container.position.y > -60:
			container.position.y -= scroll_amount
		else:
			scrollDone = true

		if scrollDone and textDone and not fadeDone:
			if get_modulate() == Color(1, 1, 1, 1):
				fadeDone = true
			else:
				set_modulate(lerp(get_modulate(), Color(1, 1, 1, 0), 0.2))

		elif fadeDone:
			playAnimation()
			finish()

func playAnimation():
	await get_tree().create_timer(1.0).timeout
	if not played:
		played = true
		animation.play("leave_screen")
	await get_tree().create_timer(2.0).timeout

func finish():
	uncovered = false
	$Cover.color = Color(0,0,0,0)
	animation.play("cover")
	await get_tree().create_timer(1.0).timeout
	sign_off_done.emit()

#func _on_leave_begin() -> void:
	#pass # Replace with function body.

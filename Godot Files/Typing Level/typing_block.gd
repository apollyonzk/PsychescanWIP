extends Node2D

var correctChars = 0
var failure = false

const defaultText = "Missing Text"
const failTimer = 1
var newText
var info
var fail = false
var timer = 0
var checked = false

@onready var label := $Control/Label
@onready var labelFail := $Control/Label_Failure
@onready var labelSucc := $Control/Label_Success

# Backup text is something goes wrong
func _ready() -> void:
	newText = defaultText
	label.text = defaultText
	labelFail.text = defaultText
	labelSucc.text = defaultText
	labelFail.visible = false
	labelSucc.visible = true
	labelFail.visible_characters = -1
	labelSucc.visible_characters = 0

func setText(text):
	newText = text
	label.text = text
	labelFail.text = text
	labelSucc.text = text
	
func setPos(pos):
	position = pos

func checkDone():
	if not labelSucc.visible_ratio == 1 or checked:
		return false
	checked = true
	return true

func completed():
	return checked

func typeChecking(event):
	if labelSucc.visible_ratio == 1:
		return
	var typedEvent = event as InputEventKey
	var typedKey = PackedByteArray([typedEvent.keycode]).get_string_from_utf8()
	if newText[correctChars].to_upper() == typedKey:
		correctChars += 1
		labelSucc.visible_characters = correctChars
	else:
		labelFail.visible = true
		labelFail.visible_characters = -1
		fail = true
		correctChars = 0
		labelSucc.visible_characters = correctChars

func move(speed):
	position.x += speed

func rightPoint():
	return label.get_global_rect().size[0]

func setInformation(information):
	info = information

func getInfo():
	return info

func checkFail(delta):
	if fail:
		if timer < failTimer:
			timer += delta
		else:
			labelFail.visible = false
			fail = false
			timer = 0

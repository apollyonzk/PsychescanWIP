extends Node

# The current minigame folder name (e.g., "launch", "psychescan", etc.)
@onready var minigame_level
# Index used to access the corresponding hint node from the list
@onready var minigame_index

# List of all hint nodes for different minigames (must match order of index assignments below)
@onready var minigame_hints = [
	$EscapeRoomHints,
	$LaunchHints,
	$MeteoroidHints,
	$MarsHints,
	$ScanHints,
	$TypingHints,
]

# Signals emitted when hints are shown or hidden
signal hint_open
signal hint_close

# Tracks the previous scene so we can detect when the minigame changes
var previous_scene_path := ""

func _process(delta: float) -> void:
	# Skip if there is no current scene loaded yet
	if get_tree().current_scene == null:
		return

	# Get the full path to the currently loaded scene
	var scene_path = get_tree().current_scene.scene_file_path
	
	# Only run the logic below if the scene has changed
	if scene_path != previous_scene_path:
		previous_scene_path = scene_path

		# Extract the folder name to identify the minigame
		var folder_name = scene_path.get_base_dir().replace("res://", "").split("/")[0]
		minigame_level = folder_name

		# Map folder names to specific index values
		match minigame_level:
			"scavenger-hunt": 
				minigame_index = 0
			"launch": 
				minigame_index = 1
			"meteoroid-level": 
				minigame_index = 2
			"marsslingshot2.0": 
				minigame_index = 3
			"psychescan": 
				minigame_index = 4
			"Typing Level": 
				minigame_index = 5
		
		# Hide all hint nodes to avoid showing the wrong one when the minigame changes
		for hint in minigame_hints:
			if hint:
				hint.visible = false

	# Show or hide the hint button depending if a minigame hint is present
	if minigame_index:
		if !minigame_hints[minigame_index]: 
			$Hint.hide()
		elif minigame_hints[minigame_index]:
			$Hint.show()

# Input buffer to capture typed characters (used for menu navigation)
var input_buffer = ""

func _input(event: InputEvent) -> void:
	# Add typed characters to the buffer
	if event is InputEventKey and event.pressed:
		if event.unicode > 0:  # Printable character
			input_buffer += char(event.unicode)
	
	# Process the input when accept is pressed
	if event.is_action_pressed("ui_accept"):
		process_input(input_buffer)
		input_buffer = ""  # Clear buffer for next input

# Dev skips to test individual minigame functionalities 
func process_input(input_text):
	if input_text == ("1"):
		Audio.play_music_rooms(-15)
		get_tree().change_scene_to_file("res://scavenger-hunt/scenes/world.tscn")
	if input_text == ("2"):
		Audio.play_music_minigame(-15)
		get_tree().change_scene_to_file("res://launch/scenes/launch.tscn")
	if input_text == ("3"):
		Audio.play_music_minigame(-15)
		get_tree().change_scene_to_file("res://meteoroid-level/scenes/start_screen.tscn")
	if input_text == ("4"):
		Audio.play_music_minigame(-15)
		get_tree().change_scene_to_file("res://marsslingshot2.0/scenes/world.tscn")
	if input_text == ("5"):
		Audio.play_music_minigame(-15)
		get_tree().change_scene_to_file("res://psychescan/levels/main_level.tscn")
	if input_text == ("6"):
		Audio.play_music_minigame(-15)
		get_tree().change_scene_to_file("res://Typing Level/TypingLevel.tscn")
	if input_text == ("7"):
		Audio.play_music_rooms(-15)
		get_tree().change_scene_to_file("res://credits/scenes/leave.tscn")

# Handle mute toggle and disable focus for better UX
func _on_mute_toggled(toggled_on: bool) -> void:
	var master_bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(master_bus_index, toggled_on)
	$Mute.focus_mode = false

# Toggle visibility of the current minigame hint when checkbox is toggled
func _on_check_box_toggled(toggled_on: bool) -> void:
	if minigame_hints[minigame_index]:
		minigame_hints[minigame_index].visible = toggled_on
		$Hint.focus_mode = false

		# Emit signal based on toggle state for use in the minigames
		if toggled_on:
			hint_open.emit()
		else:
			hint_close.emit()

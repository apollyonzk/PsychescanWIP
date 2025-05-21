extends Control


# Kuiper's dialogue, displayed one line at a time
var text = [
		"Hello!",
		"My name is Kuiper (pronounced like KY-per) and I need your help!",
		"I am a part of the Psyche (pronounced like SY-kee) Team.",
		"For the first time ever, we are exploring a world made not of rock or ice, but of metal.",
		"Most asteroids are made of a combination of rock and ice except this one.",
		"This metal-rich asteroid is named Psyche.",
		"I need your help to get me to the control room to launch the spacecraft!",
		"Then I'll need your help on the computer carrying out parts of the mission!",
		"Let's go!"
		]

@onready var label := $Story/Label   # Label node where dialogue is shown
const base_speed := 40               # How fast the characters appear on screen (higher = faster)
var started := true                  # Whether we’ve started showing the first dialogue line
var finished := false                # Whether all dialogue is finished 
var count := 0.0                     # Used to control time between character reveals
var covered = true                   # True if the prompt cover is still on screen
var start = false                    # Whether the scene has started
var ending := false                  # Prevents triggering ending multiple times

var volume = -35                     # Initial volume level for background music

func _ready() -> void:
	Audio.play_music_rooms(volume)
	
	# Black out the screen initially
	$Cover.color = Color(0,0,0)
	$PromptCover.color = Color(0,0,0)
	$Cover.show()
	$PromptCover.show()
	
	# Wait, then fade out the cover animation
	await get_tree().create_timer(1.0).timeout
	$AnimationPlayer.play("cover_fade")
	
	# Wait for animation, then hide the black cover
	await get_tree().create_timer(1.0).timeout
	$Cover.hide()
	
	# Then, start the dialogue
	start = true

func _process(delta: float) -> void:
	if start:
		# If text hasn't fully appeared yet
		if label.get_visible_ratio() != 1.0:
			if(count < 1):
				count += base_speed*delta
			else:
				# Reveal one more character
				label.set_visible_characters(label.get_visible_characters()+1)
				# Play dialogue beep sound every 2 characters
				if (label.get_visible_characters() % 2 == 0):
					$Audio/sfx_dialogue.play()
				count -= 1
		# Text fully visible, fade in prompt indicator
		else:
			if covered:
				covered = false
				$AnimationPlayer.play("prompt_cover_fade")
		if started:
			changeText()
			started = false

# Go through each line of text
func changeText():
	if text.size() > 0:
		label.set_visible_ratio(0.0) 
		label.text = text.pop_front()
		# Trigger Psyche reveal animation based on specific lines
		if label.text == "Most asteroids are made of a combination of rock and ice except this one.":
			$AnimationPlayer2.play("psyche_cover_fade")
		if label.text == "I need your help to get me to the control room to launch the spacecraft!":
			$AnimationPlayer2.play("psyche_cover")
	else: 
		# Once all text has been displayed, dialogue is finished
		finished = true

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		if !finished:
			covered = true
			$AnimationPlayer.play("prompt_cover")    # Cover the prompt while changing text
			if(label.get_visible_ratio() == 1.0):    # If line is fully shown, move to next
				changeText()
		if finished && !ending:                      # If done with all text and not already ending
			ending = true
			Audio.volume_db += 5                     # Slightly increase volume
			
			# Fade to black
			$Cover.show()
			await get_tree().create_timer(0.2).timeout
			$AnimationPlayer.play("cover")
			await get_tree().create_timer(1.1).timeout
			
			# Hide all visual elements
			$Story.hide()
			$Player.hide()
			$Prompt.hide()
			$Psyche1.hide()
			
			Audio.volume_db += 5                    # Slightly increase volume
			
			# Start escape room minigame
			get_tree().change_scene_to_file("res://scavenger-hunt/scenes/world.tscn")
			
	# Dev skip to skip over dialogue
	if event.is_action_pressed("interact"):
		while text.size() != 0:
			covered = true
			$AnimationPlayer.play("prompt_cover")
			if(label.get_visible_ratio() == 1.0):
				changeText()
			else:
				label.set_visible_ratio(1.0)

#func _on_ready_pressed() -> void:
	

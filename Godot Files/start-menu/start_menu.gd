extends Control

signal from_start

@onready var wait = 1.1
@onready var volume = -50
@onready var change_by = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer2.play("move_psyche")
	Audio.volume_db = volume
	Audio.play_music_start(volume)
	$Feedback.hide()
	$Cover.color = Color(0,0,0,1)
	$Cover.show()
	$ButtonCover.show()
	$Logo.show()
	$AnimationPlayer.play("cover_fade")                   # Cover Psyche logo - "fade to black"
	await get_tree().create_timer(2*wait).timeout      # Wait 2 wait seconds before covering the Psyche logo
	Audio.volume_db += change_by
	$AnimationPlayer.play("cover")                   # Cover Psyche logo - "fade to black"
	await get_tree().create_timer(wait).timeout      # Wait 1 second to let the animation to finish
	Audio.volume_db += change_by
	$Logo.hide()                                    # Hide the Pysche logo
	$Cover.show()                                   # Show the cover
	$AnimationPlayer.play("cover")                  # Cover the logo - "fade to black"
	await get_tree().create_timer(wait).timeout      # Wait 1 second to let the animation to finish
	Audio.volume_db += change_by
	$ButtonCover.hide()                             # Hide the button cover to show the start and credits buttons
	$AnimationPlayer.play("cover_fade")             # Fade the cover 
	await get_tree().create_timer(wait).timeout      # Wait 1 minute to let the animation finish 
	Audio.volume_db += change_by
	$Cover.hide() 

func _on_start_pressed() -> void:                   # When the start button is pressed 
	Audio.volume_db -= 10
	$Cover.show()                                   # Show the cover 
	$AnimationPlayer.play("cover")                  # Cover the start menu - "fade to black"
	await get_tree().create_timer(wait).timeout      # Wait 1.0 seconds to let the animation finish 
	Audio.volume_db -= 10
	get_tree().change_scene_to_file("res://scavenger-hunt/scenes/instructions.tscn")   # Change the scence to the scavenger hunt minigame 
	Audio.stop()

func _on_credits_pressed() -> void:                 # When the credits button is pressed 
	Audio.volume_db += change_by
	$Cover.show()                                   # Show the cover
	$AnimationPlayer.play("cover")                  # Cover the start menu - "fade to black"
	from_start.emit()
	await get_tree().create_timer(wait).timeout      # Wait 1.0 seconds to let the animation finish 
	Audio.volume_db += change_by
	get_tree().change_scene_to_file("res://credits/scenes/leave.tscn")   # Change the scence to the credits screen 

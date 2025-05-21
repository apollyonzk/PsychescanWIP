# script for first part of meteoroid level

extends Node2D

@onready var timer: Timer = $Timer
@onready var shuttle: CharacterBody2D = $Shuttle
@onready var color_rect: ColorRect = $ColorRect
@onready var win_sound: AudioStreamPlayer2D = $WinSound
@onready var lose_sound: AudioStreamPlayer2D = $LoseSound
@onready var target_highlight: ColorRect = $TargetHighlight


func win_screen():
	timer.start()
	win_sound.play()
	var tween = create_tween()
	tween.tween_property(color_rect, "color", Color8(0, 255, 0, 100), 2.0) # win color is green, opacity change
	await tween.finished


func load_next_screen():
	get_tree().call_deferred("change_scene_to_file", "res://meteoroid-level/scenes/level_2_screen.tscn")


func _on_ready() -> void:
	color_rect.color = Color8(0, 255, 0, 0) # set color panel to green
	shuttle.level_1_changes() # calls level setting changes to shuttle's max inputs and winning tile
	
	target_highlight.color = Color8(255, 255, 0, 0) # set color panel to yellow
	
	var tween = create_tween() # animation for target tile highlighting
	
	tween.tween_property(target_highlight, "color", Color8(255, 255, 0, 100), 1.0) # opacity change to visible
	tween.tween_property(target_highlight, "color", Color8(255, 255, 0, 0), 1.0) # opacity change to invisible
	
	tween.set_loops()


func _on_timer_timeout() -> void:
	load_next_screen()

func lose_screen() -> void:
	lose_sound.play()
	color_rect.color = Color8(255, 0, 0, 0) # set color panel to red
	
	var tween = create_tween()
	tween.tween_property(color_rect, "color", Color8(255, 0, 0, 100), 2.0) # animate opacity over time
	await tween.finished
	
	get_tree().call_deferred("reload_current_scene")

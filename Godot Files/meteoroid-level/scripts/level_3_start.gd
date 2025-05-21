# script for start button on level 3

extends Button
@onready var clicksound: AudioStreamPlayer2D = $"../../Clicksound"
@onready var timer: Timer = $"../../Timer"


func _on_pressed() -> void:
	clicksound.volume_db = 15
	clicksound.play()
	timer.start()
	


func _on_timer_timeout() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://meteoroid-level/scenes/level_3.tscn")

# Killzone script to detect collision and restart level

extends Area2D

@onready var timer: Timer = $Timer # reference to timer node in killzone scene, set to 2 sec


func _on_body_entered(_body: Node2D) -> void:
	timer.start()
	var color_screen = get_tree().current_scene.get_node("ColorRect") # retrieve reference to color panel in level scene
	var lose_sound = get_tree().current_scene.get_node("LoseSound") # retrieve reference to loss sound in level scene
	color_screen.color = Color8(255, 0, 0, 0) # set color to red
	lose_sound.play()
	
	_body.queue_free() # remove shuttle from scene so level doesn't keep playing
	
	var tween = create_tween()
	tween.tween_property(color_screen, "color", Color8(255, 0, 0, 100), 2.0) # changes opacity over time
	await tween.finished

func _on_timer_timeout() -> void:
	get_tree().call_deferred("reload_current_scene") # Reloads scene upon hitting zone

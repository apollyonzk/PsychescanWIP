# Code for target area visual indicator (sparkle effect)
extends AnimatedSprite2D

func _ready() -> void:
	var timer = get_node("Timer")
	timer.start()

# Loop animation	
func _on_timer_timeout() -> void:
	play("sparkle")
	await get_tree().create_timer(1.0).timeout  # Wait while animation plays
	stop()
	$Timer.start()

# Asteroid movement script
# Movement is inverted to mimic the effect of player controlling a camera/sensor

extends CharacterBody2D

const SPEED: float = 200.0

func _physics_process(_delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up" , "ui_down")
	direction = Vector2(-direction.x, -direction.y)  # inverts controls (up is down left is right etc.)
	velocity = direction * SPEED

	move_and_slide()

extends CharacterBody2D

var input = Vector2.ZERO
const acceleration = 100
const max_speed = 5000
const SPEED = 50.0
const JUMP_VELOCITY = -400.0
var gas = true


func _physics_process(delta: float) -> void:
	player_movement(delta)
	velocity += get_gravity()
	move_and_slide()

func get_input():
	input.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	input.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	return input.normalized()
	
func player_movement(delta):
	if gas:
	#input = get_input()

#	velocity += (input * acceleration * delta)
#	velocity = velocity.limit_length(max_speed)
		
		if Input.is_action_pressed("ui_left"):
			rotate(-.05)
			
		if Input.is_action_pressed("ui_right"):
			rotate(.05)
		
		if Input.is_action_pressed("ui_up"):
			velocity += transform.x * SPEED * delta

		
		move_and_slide()


func _on_timer_timeout() -> void:
	gas = false
	print("out of gas")

func get_time_left() :
	return $Timer.time_left
	

extends Timer

var count = 0
var time = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	use_boost()
	time = time_left
	if is_stopped():
			start()
			paused = true
	


func use_boost():
	if Input.is_action_just_pressed("ui_up"):
		paused = false
		print(time_left)
	if Input.is_action_just_released("ui_up"):
		paused = true

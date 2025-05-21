extends Node2D

var count = 0
var number: float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	set_label()
	set_size_colorrect()

func set_label() -> void:
	number = sqrt($space_ship.velocity.x*$space_ship.velocity.x + $space_ship.velocity.y * $space_ship.velocity.y)
	$Label.text = str(number).pad_decimals(2)
	Globals.velocity2 = str(number).pad_decimals(2)

func set_size_colorrect() :
	$ColorRect.size.x = $space_ship/Timer.get_time_left() * 300


func _on_timer_timeout() -> void:
	$ColorRect.visible = false # Replace with function body.


func _on_game_area_body_exited(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://marsslingshot2.0/scenes/off_course.tscn")

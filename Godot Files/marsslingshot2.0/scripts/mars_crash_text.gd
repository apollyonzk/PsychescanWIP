extends RichTextLabel

var count = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("check")
	if body != $CollisionShape2D:
		visible = true
	count += 1
	


func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()

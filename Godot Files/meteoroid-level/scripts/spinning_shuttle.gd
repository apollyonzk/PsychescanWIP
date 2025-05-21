# script to rotate shuttle in the start screen

extends Sprite2D
const ROTATION_SPEED = 0.5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation += ROTATION_SPEED * delta

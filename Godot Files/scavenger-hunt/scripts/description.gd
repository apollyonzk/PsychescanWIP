extends Control

var open := false  # Whether popup box is open

func _process(delta: float) -> void:
	if visible:          # If popup is visible, open is true
		open = true
	else:
		open = false
	

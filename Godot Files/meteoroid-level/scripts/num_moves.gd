# script for showing the number of moves player has made so far

extends Label

@onready var shuttle: CharacterBody2D = $"../Shuttle"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if shuttle != null: # for when the shuttle collides and the node is freed
		text = "# of moves: " + str(shuttle.input_array.size()) + "/" + str(shuttle.MAX_MOVES) # counts number of valid inputs from user

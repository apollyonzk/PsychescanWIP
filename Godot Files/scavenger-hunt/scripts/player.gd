extends CharacterBody2D

const WALK_FORCE = 3000               # Acceleration force for movement input
const WALK_MAX_SPEED = 1000           # Maximum movement speed in any direction
const STOP_FORCE = 2600               # Deceleration force when input stops

var direction                         # Stores current direction ("up", "down", etc.)
var movable = false                   # Whether player is movable
var moving = false                    # Whether player is currently moving (mostly for cutscenes)

@export var sfx_footsteps : AudioStream       # Footstep sound effect
var footstep_frames : Array = [1, 4]          # Frames where footstep sounds play

@onready var arrow = $RayCast2D               # Used to detect interactable objects in front of the player

signal interact                               # Emitted if RayCast2D hits something
signal no_interact                            # Emitted if RayCast2D hits nothing

var arrow_length = 13                         # Length of RayCast2D vector

var popup_open := false                        # True if a popup is active

func _physics_process(delta):
	move_player()

func move_player():
	# Only allow movement if not blocked by popup
	if movable:                                                                
		# Horizontal movement                                   
		var walk_x = WALK_FORCE * (-1 if Input.is_action_pressed("ui_left") else 1 if Input.is_action_pressed("ui_right") else 0)
		if walk_x < 0:                                             # If left was pressed
			direction = "left"                                     # Set direction to "left"
			arrow.target_position = Vector2(-arrow_length, 0)      # Set direction of RayCast2D to face left
		if walk_x > 0:                                             # If right was pressed
			direction = "right"                                    # Set direciton to "right"
			arrow.target_position = Vector2(arrow_length, 0)       # Set direction of RayCast2D to face right 
		if abs(walk_x) < WALK_FORCE * 0.2:                         # Slow down the player if they're not trying to move.
			# Set idle animation depending on direction
			if direction == "left":                                             
				$PlayerSprite.play("idle_left")
			if direction == "right":
				$PlayerSprite.play("idle_right")
			# The velocity, slowed down a bit, and then reassigned.
			velocity.x = move_toward(velocity.x, 0, STOP_FORCE)
		else:
			# Apply horizontal acceleration
			velocity.x += walk_x
		
		# Clamp to the maximum horizontal movement speed.
		velocity.x = clamp(velocity.x, -WALK_MAX_SPEED, WALK_MAX_SPEED)

		# Vertical movement code, same as above
		var walk_y = WALK_FORCE * (-1 if Input.is_action_pressed("ui_up") else 1 if Input.is_action_pressed("ui_down") else 0)
		if walk_y < 0:
			direction = "up"
			arrow.target_position = Vector2(0, -arrow_length)
		if walk_y > 0:
			direction = "down"
			arrow.target_position = Vector2(0, arrow_length)
		# Slow down the player if they're not trying to move.
		if abs(walk_y) < WALK_FORCE * 0.2:
			if direction == "up":
				$PlayerSprite.play("idle_up")
			if direction == "down":
				$PlayerSprite.play("idle_down")
			# The velocity, slowed down a bit, and then reassigned.
			velocity.y = move_toward(velocity.y, 0, STOP_FORCE)
			
		else:
			velocity.y += walk_y

		# Clamp to the maximum horizontal movement speed.
		velocity.y = clamp(velocity.y, -WALK_MAX_SPEED, WALK_MAX_SPEED)

		# Move based on the velocity.
		move_and_slide()
		
		# Check if player can interact with something
		if (arrow.is_colliding()):
			interact.emit()
		else:
			no_interact.emit()
			
		# Ensure correct animation is playing 
		if velocity.length() > 0:  # If moving
			if direction == "up" and $PlayerSprite.animation != "walk_up":
				$PlayerSprite.play("walk_up")
			elif direction == "down" and $PlayerSprite.animation != "walk_down":
				$PlayerSprite.play("walk_down")
			elif direction == "left" and $PlayerSprite.animation != "walk_left":
				$PlayerSprite.play("walk_left")
			elif direction == "right" and $PlayerSprite.animation != "walk_right":
				$PlayerSprite.play("walk_right")
		else:  # If stopped, play idle animation
			if direction == "up" and $PlayerSprite.animation != "idle_up":
				$PlayerSprite.play("idle_up")
			elif direction == "down" and $PlayerSprite.animation != "idle_down":
				$PlayerSprite.play("idle_down")
			elif direction == "left" and $PlayerSprite.animation != "idle_left":
				$PlayerSprite.play("idle_left")
			elif direction == "right" and $PlayerSprite.animation != "idle_right":
				$PlayerSprite.play("idle_right")

# Room popup handling
func _on_room_1_popup_close() -> void:
	movable = true
	popup_open = false

func _on_room_1_popup_open() -> void:
	movable = false
	moving = false
	popup_open = true

func _on_room_2_popup_close() -> void:
	movable = true
	popup_open = false

func _on_room_2_popup_open() -> void:
	moving = false
	movable = false
	popup_open = true

func _on_room_3_popup_close() -> void:
	movable = true
	popup_open = false

func _on_room_3_popup_open() -> void:
	moving = false
	movable = false
	popup_open = true

# Sound effect handling
func load_sfx(sfx_to_load):
	if $Audio/sfx_player.stream != sfx_to_load:
		$Audio/sfx_player.stop()
		$Audio/sfx_player.stream = sfx_to_load

# Footstep sound handling
func _on_player_sprite_frame_changed() -> void:
	if "idle" in $PlayerSprite.animation:  # Skip if idle
		return

	if sfx_footsteps:  # Ensure the sound is assigned
		load_sfx(sfx_footsteps)

	if $PlayerSprite.frame in footstep_frames and (moving or movable):
		if !$Audio/sfx_player.playing:  # Prevent overlapping sounds
			$Audio/sfx_player.play()

# Used for audio/sfx logic during cutscenes
func _on_world_is_moving() -> void:
	moving = true

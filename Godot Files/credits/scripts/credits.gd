extends CanvasLayer

# Signal emitted when credits are finished
signal done

# Flags to track state
var from_start_menu := false
var going := true          # Determines if credits should be scrolling
var wait_time = 1.1        # Time to wait before fading out at the end

# Timings and scroll speed values
const section_time := 0.0           # Time delay between credit sections
const line_time := 0.0              # Time delay between individual lines
const base_speed := 170             # Base scroll speed of text

# Appearance
var title_color = Color.html("#f9a000")  # Color for section titles

# Current scroll speed
var scroll_speed := base_speed

# Label node used as the template for each credit line
@onready var line := $CreditsContainer/Label

# Flags and variables for section tracking
var started := false
var section                        # Current section of text
var section_next := true           # Whether to load a new section
var section_timer := 0.0           # Time accumulator between sections
var line_timer := 0.0              # Time accumulator between lines
var curr_line := 0                 # Index of current line within the section
var lines := []                    # Active on-screen lines

var credits = [
	[
		"Disclaimer",
		"This work was created in partial fulfillment of Seattle ",
		"University Capstone Program. The work is a result ",
		"of the Psyche Student Collaborations component of NASA's ",
		"Psyche Mission (https://psyche.asu.edu). 'Psyche: A Journey to ",
		"a Metal World'[Contract number NNM16AA09C] is part of the ",
		"NASA Discovery Program mission to solar system targets.",
		"Trade names and trademarks of ASU and NASA are used in this",
		"work for identification only. Their usage does not constitute",
		"an official endorsement, either expressed or implied, by",
		"Arizona State University or National Aeronautics and Space",
		"Administration. The content is solely the responsibility of",
		"the authors and does not necessarily represent the official",
		"views of ASU or NASA."
	],[
		"Programmers",
		"Grace Lane",
		"Kevin Bui",
		"Hanjin Jacobs",
		"Lyle Vitales",
		"Colin Curry",
	],[
		"Artists",
		"Adapted by Grace Lane from LimeZu (https://limezu.itch.io/)",
		"Grace Lane",
		"Kevin Bui",
	],[
		"Music",
		"https://haberchuck.itch.io/pc-98-visual-novel-bgm-pack",
	],[
		"Sound Effects",
		"https://dryoma.itch.io/footsteps-sounds",
		"https://liminal-space-dev.itch.io/free-horror-sfx-sounds",
	],[
		"Tools",
		"Developed with Godot Engine https://godotengine.org/license",
		"Procreate",
		"Microsoft Paint"
	],[
		"Beta Testers",
		"Mason Welch",
		"Oliver - Kobe - Ryder - Jaxson - Abram",
		"Harper - Hunter - Oliver - Hazel",
		"Ben - Brendan - Emma - Ari - Clyde",
		"Halle - Harper - Yeji - Hazel",
		"Michael - Hannah - Yian - Whitney",
		"Makenna - Saylor - Fiona - Elliot",
		"Wyatt - Charlie - Lucas - Anton - Leila",
		"Luca - Taylor - Mia - Elliot - Ben",
		"Christopher - Abigail - Kailine - Christian",
		"Christian B.",
		"Eduardo C-J",
		"Christopher K.",
		"Abigail K.",
		"Elijah M.",
		"Joshua M.",
		"Bryant T.",
		"Todd P.",
		"Alex T.",
	],[
		"Special Thanks To",
		"Dr. Nate Kremer-Herman, PhD",
		"Dr. Cassie Bowman, EdD",
	],
]

func _process(delta):
	if going:                                               # To ensure this runs only when it is supposed to
		var scroll_speed = base_speed * delta               # Speed at which the credits scroll
		
		if section_next:
			section_timer += delta
			if section_timer >= section_time:               # If there is a delay between sections
				section_timer -= section_time
				
				if credits.size() > 0:                      # If there are still credits to be read out
					started = true
					section = credits.pop_front()
					curr_line = 0
					add_line()
		
		else:                                               # Within the sections
			line_timer += delta
			if line_timer >= line_time:                     # If there is a delay between lines
				line_timer -= line_time
				add_line()
		
		if lines.size() > 0:                                    # If there are still more lines
			for l in lines:                                     # For each line
				l.global_position.y -= scroll_speed             # Change the position of the line 
				if l.global_position.y < -l.get_line_height():  # Once it moves off the screen, remove it from the lines and free it
					lines.erase(l)
					l.queue_free()
		elif started:                                           # If no more lines, but have already started, then finish
			finish()

# Add new line
func add_line():
	var new_line = line.duplicate()
	new_line.text = section.pop_front()
	
	 # If it's first line, the color is special to indicate it's the title of the section
	if curr_line == 0:                                                 
		new_line.set("theme_override_colors/font_color", title_color)

	$CreditsContainer.add_child(new_line)

	# Set initial position based on last line
	var y_offset = 0
	if lines.size() > 0:
		var last_line = lines[lines.size() - 1]
		
		# GDScript-style ternary operator
		var extra_spacing = 150 if curr_line == 0 else 50
		y_offset = last_line.global_position.y + last_line.get_line_height() + extra_spacing
	else:
		# Start offscreen at bottom
		y_offset = get_viewport().get_visible_rect().size.y

	var screen_center_x = get_viewport().get_visible_rect().size.x / 2
	new_line.global_position = Vector2(screen_center_x - new_line.size.x / 2, y_offset)    # Center it on the screen

	lines.append(new_line)

	if section.size() > 0:       # If the section still has content, don't move to the next section
		curr_line += 1
		section_next = false
	else:
		section_next = true

func finish():
	going = false          # Ensures code in _process does not run anymore
	started = false
	thank_you()

func thank_you():
	$AnimationPlayer.play("fade_in")                    # Fade in the personal thank you message
	await get_tree().create_timer(3*wait_time).timeout
	$AnimationPlayer.play("fade_out")                    # Fade out the personal thank you message
	await get_tree().create_timer(wait_time).timeout
	done.emit()                                         # Emit the done signal

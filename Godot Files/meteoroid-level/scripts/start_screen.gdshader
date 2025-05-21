// shader to have the background scroll horizontally
shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
	UV.x += TIME * 0.1;
}

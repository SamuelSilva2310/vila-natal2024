extends Node

@export var present_scene: PackedScene
@export var floor: MeshInstance3D
@export var push_force: float = 2
@export var gentle_push_force: float = 0.5  # Gentle push to apply after spawn
@export var removal_threshold_y: float = -10.0
@export var spawn_height: float = 10.0  # Dynamic height for spawning presents


var current_present: RigidBody3D = null

# Remove the current present from the scene
func remove_present():
	if current_present:
		current_present.queue_free()
		current_present = null

func show_image(image: Image):

	var canvas: CanvasLayer = $CanvasLayer
	var texture = ImageTexture.create_from_image(image)
	var texture_rect: TextureRect = canvas.get_child(0)
	
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	texture_rect.texture = texture

	canvas.add_child(texture_rect)


# Spawn a new present with the given dynamic height
func spawn_present(image = null):

	show_image(image)

	if current_present:
		remove_present()

	# Instance the new present scene
	current_present = present_scene.instantiate() as RigidBody3D
	current_present.add_image_to_present(image)
	get_tree().root.add_child(current_present)

	# Position the present with a dynamic spawn height
	var position = calculate_spawn_position()
	current_present.global_position = position

	# Apply a gentle push to the present
	var push_direction = calculate_push_direction(position)
	apply_push(current_present, push_direction)


# Handle updates from fetched data (removes the old present, if any, and spawns a new one)
func update_present(data):
	print("Updating present")
	if current_present:
		remove_present()  # Remove the old present
	spawn_present(data)

# Check if the present falls below the threshold and remove it
func _process(delta):
	if current_present and current_present.global_position.y < removal_threshold_y:
		remove_present()  # Remove the present if it falls too low

# Calculate random spawn position
func calculate_spawn_position() -> Vector3:
	var aabb = floor.get_aabb()
	var random_x = randf_range(aabb.position.x, aabb.position.x + aabb.size.x)
	var random_z = randf_range(aabb.position.z, aabb.position.z + aabb.size.z)
	var random_y = spawn_height  # Spawn at the specified dynamic height
	return Vector3(random_x, random_y, random_z)

# Calculate push direction (random direction left or right)
func calculate_push_direction(position: Vector3) -> Vector3:
	var center_x = floor.get_aabb().position.x + floor.get_aabb().size.x / 2
	return Vector3(-1, 0, 0) if position.x < center_x else Vector3(1, 0, 0)

# Apply a push impulse to the present (using the dynamic push force)
func apply_push(present: RigidBody3D, direction: Vector3):
	present.apply_impulse(Vector3.ZERO, direction * push_force)  # Apply the primary push force

	# Apply a gentle push to add some variation to the movement
	present.apply_impulse(Vector3.ZERO, direction * gentle_push_force)  # Apply gentle push after main push

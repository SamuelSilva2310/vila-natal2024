extends Node

@export var present_scene: PackedScene
@export var floor: MeshInstance3D

@export var push_force: float = 2
@export var removal_threshold_y: float = -10.0
@export var spawn_height: float = 10.0  # Dynamic height for spawning presents


var current_present: RigidBody3D = null


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

	#####################
	# DO SOME ANIMATION #
	#####################


# Handle updates from fetched data (removes the old present, if any, and spawns a new one)
func update_present(data):
	if current_present:
		remove_present()  # Remove the old present
	spawn_present(data)


func _process(delta):
	if current_present and current_present.global_position.y < removal_threshold_y:
		remove_present()  # Remove the present if it falls too low

# Calculate random spawn position
func calculate_spawn_position() -> Vector3:
	var aabb = floor.get_aabb()
	var random_y = spawn_height

	return Vector3(0, random_y, 0)

# Calculate push direction (random direction left or right)
func calculate_push_direction(position: Vector3) -> Vector3:
	var center_x = floor.get_aabb().position.x + floor.get_aabb().size.x / 2
	return Vector3(-1, 0, 0) if position.x < center_x else Vector3(1, 0, 0)

# Apply a push impulse to the present (using the dynamic push force)
func apply_push(present: RigidBody3D, direction: Vector3):
	present.apply_impulse(Vector3.ZERO, direction * push_force)  # Apply the primary push force
	

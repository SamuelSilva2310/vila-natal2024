extends Node

@export var present_scene: PackedScene = preload("res://present.tscn")

@export var push_force: float = 2
@export var removal_threshold_y: float = -10.0
@export var spawn_height: float = 10.0  # Dynamic height for spawning presents
@export var spawn_distance: float = 1.0  # Dynamic height for spawning presents

@export var hover_amplitude: float = 0.15 # Distance for hover
@export var hover_speed: float = 1.25  # Speed of the floating effect
@export var floating_duration: float = 5.0  # Time to float before dropping
@export var drop_duration: float = 3.0  # Time to float before dropping
@export var float_y_offset: float = 0.5 # Offset down, where the present hovers


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
    current_present.set_properties(get_floating_position(), hover_amplitude, hover_speed, floating_duration, drop_duration)
    var position = calculate_spawn_position()
    current_present.global_position = position
    current_present.add_image_to_present(image)

    get_tree().root.add_child(current_present)




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
    var position = get_spawn_position()
    print("calculate_spawn_position %s" % position)

    return position


func get_spawn_position():
    # Get the camera's global position
    var camera = get_parent().get_node("Camera3D")
    print("Camera %s" % camera)
    var camera_position = camera.global_transform.origin
    print("Camera position %s" % camera_position)

    # Get the forward direction of the camera (negative Z axis)
    var forward_direction = -camera.global_transform.basis.z.normalized()
    print("forward_direction %s" % forward_direction)

    # Calculate the spawn position relative to the camera
    var spawn_position = camera_position + forward_direction * spawn_distance + Vector3(0, spawn_height, 0)
    print("spawn_position %s" % spawn_position)

    return spawn_position


func get_floating_position() -> Vector3:
    # Get the camera node
    var camera = get_parent().get_node("Camera3D")
    if not camera:
        print("Camera3D not found!")
        return Vector3.ZERO

    # Get the viewport's size and calculate the center point
    var viewport = get_viewport()
    var viewport_center = viewport.get_visible_rect().size / 2
    print("[PRESENT MANAGER] viewport_center %s" % viewport_center)

    # Project the center of the screen into 3D space
    var ray_origin = camera.project_ray_origin(viewport_center)
    var ray_direction = camera.project_ray_normal(viewport_center).normalized()

    print("[PRESENT MANAGER] ray_origin %s" % ray_origin)
    print("[PRESENT MANAGER] ray_direction %s" % ray_direction)

    # Calculate the spawn position based on the ray direction
    var spawn_position = ray_origin + ray_direction * spawn_distance
    print("[PRESENT MANAGER] spawn_position %s" % spawn_position)

    # Set the floating position to the same as the spawn position
    var float_position = spawn_position - Vector3(0, float_y_offset,0)
    print("[PRESENT MANAGER] float_position %s" % float_position)


    return float_position

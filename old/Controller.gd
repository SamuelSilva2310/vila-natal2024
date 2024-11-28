extends Node3D

# Preload the 'present' scene
@export var present_scene: PackedScene = preload("res://present.tscn")

# Define spawn boundaries
@export var spawn_offset_min_y: float = 0.5
@export var spawn_offset_y: float = 0.5
@export var push_force: float = 2

# Reference to the camera
@export var camera: Camera3D  # Link to the camera in the scene via the inspector

# Y threshold below which the presents will be removed (adjust to your needs)
@export var removal_threshold_y: float = -10.0  # Remove present when y < -10.0

var presents: Array = []

# Function to apply an impulse (small push) to the spawned object
func apply_push(present_instance: RigidBody3D, direction: Vector3) -> void:
    present_instance.apply_impulse(Vector3.ZERO, direction * push_force)  # Apply the impulse at the center of the object
    present_instance.axis_lock_linear_z = true

func new_present() -> void:

    presents.clear()
    # Instance the 3D present scene
    var present_instance = present_scene.instantiate() as RigidBody3D
    add_child(present_instance)
    
    # Call the method to add the image to the mesh
    present_instance.add_image_to_mesh()

    # Get the floor's bounding box (AABB)
    var floor_aabb: AABB = get_node("Floor/MeshInstance3D").get_aabb()

    # Calculate boundaries based on the AABB of the floor
    var min_x = floor_aabb.position.x
    var max_x = floor_aabb.position.x + floor_aabb.size.x
    var min_y = floor_aabb.position.y + spawn_offset_y
    var min_z = floor_aabb.position.z
    var max_z = floor_aabb.position.z + floor_aabb.size.z

    # Generate random X, Y, and Z positions within the boundaries
    var random_x = randf_range(min_x, max_x)
    var random_y = min_y + spawn_offset_min_y  # Keep the Y constant above the floor
    var random_z = randf_range(min_z, max_z)

    # Set the position of the present
    present_instance.global_position = Vector3(random_x, random_y, random_z)

    # Determine if the object spawned on the left or right half of the floor
    var floor_center_x = (min_x + max_x) / 2

    if random_x < floor_center_x:
        apply_push(present_instance, Vector3(-1, 0, 0))  # Left side
    else:
        apply_push(present_instance, Vector3(1, 0, 0))   # Right side

    # Add a dictionary to track the present's visibility and object reference
    presents.append({
        "present": present_instance,
        "has_been_visible": false
    })

# Function to check if the present has fallen below a certain height (removal threshold)
func has_fallen_below_threshold(present_instance: RigidBody3D) -> bool:
    return present_instance.global_position.y < removal_threshold_y

# Function to check if the present is currently visible in the camera's frustum
func is_in_camera_view(present_instance: RigidBody3D) -> bool:
    return camera.is_position_in_frustum(present_instance.global_position)

# Called every frame.
func _process(_delta):

    print("Present instances: ", presents.size())
    if Input.is_action_pressed("ui_accept"):
        new_present()

    # Iterate through all presents
    for present_data in presents:
        var present_instance = present_data["present"]
        var has_been_visible = present_data["has_been_visible"]

        # Check if the present is currently in the camera's view
        if is_in_camera_view(present_instance):
            # If the present has been in view at least once, update the flag
            present_data["has_been_visible"] = true

        # If the present has been visible at least once and has fallen below the threshold, remove it
        if has_been_visible and has_fallen_below_threshold(present_instance):
            present_instance.queue_free()
            presents.erase(present_data)  # Remove it from the list
            #print("Present removed because it has fallen out of view after being visible.")

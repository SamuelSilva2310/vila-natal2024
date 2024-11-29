extends RigidBody3D

@export var image_texture: Texture2D = preload("res://image.png")  # Preload the image


var is_floating: bool = false  # Controls whether the object is floating
var base_position: Vector3  # Tracks the floating base position
var time : float

var float_position : Vector3
var hover_amplitude: float # Distance for hover
var hover_speed: float  # Speed of the floating effect
var floating_duration: float  # Time to float before dropping
var drop_duration: float  # Time to float before dropping

func alignImage(image: Image):
    
    if not image.has_meta("orientation"):
        return
    
    var orientation = int(image.get_meta("orientation"))
    print("orientation: %s" % orientation)
    if orientation == null:
        print("Warning: No EXIF orientation data found.")
        return

    # Use a match statement to handle different orientation cases
    match orientation:
        1:
            # Orientation 1 means the image is already correctly aligned
            return
        3:
            # 180 degrees rotation for upside-down images
            image.rotate_180()
        6:
            # 90 degrees clockwise for rotated landscape images
            image.rotate_90(CLOCKWISE)
        8:
            # 90 degrees counterclockwise for rotated landscape images
            image.rotate_90(COUNTERCLOCKWISE)
        _:
            # Handle unexpected or unknown orientation values
            print("Warning: Unhandled orientation value: %d" % orientation)
            return
    return

func add_image_to_present(image: Image):
    print("[DEBUG] Adding new image to present")

    var mesh : MeshInstance3D = get_node("MeshInstance3D")
    if not mesh:
        return

    if image:

                  
        alignImage(image)
        var material = mesh.get_active_material(0)
        material.albedo_texture = ImageTexture.create_from_image(image)

func _ready():

    sleeping = true  # Prevent physics interference
    freeze = true
    print("[PRESENT INSTANCE] Initial position: %s" % transform.origin)
    print("[PRESENT INSTANCE] Float position: %s" % float_position)
    print("[PRESENT INSTANCE] hover_amplitude: %s" % hover_amplitude)
    print("[PRESENT INSTANCE] hover_speed: %s" % hover_speed)
    print("[PRESENT INSTANCE] floating_duration: %s" % floating_duration)
    print("[PRESENT INSTANCE] drop_duration: %s" % drop_duration)
    
    drop_to_position(float_position)

func _physics_process(delta):
    time += delta
    #print("Position %s" % global_transform.origin)
    if is_floating:
        # Apply floating (bobbing) effect relative to the base position
        var offset_y = hover_amplitude * sin(time * hover_speed)
        global_transform.origin = base_position + Vector3(0, offset_y, 0)
        return

func drop_to_position(target_position: Vector3):
    # Smoothly drop the object to a specified position
    var tween = create_tween()
    tween.tween_property(self, "global_transform:origin", target_position, drop_duration)
    tween.set_trans(Tween.TRANS_LINEAR)
    tween.set_ease(Tween.EASE_IN_OUT)
    tween.connect("finished", self._on_reach_position)
    

func _on_reach_position():
    if global_transform.origin == float_position:
        # Step 3: Start floating at the current position
        start_floating()
        print("Start floating")

    else:
        # Step 4: Activate physics for final drop
        activate_physics()

func start_floating():
    # Enable floating and start the floating timer
    is_floating = true
    base_position = global_transform.origin  # Set the base position for bobbing
    get_tree().create_timer(floating_duration).connect("timeout", self._on_floating_timeout)

func _on_floating_timeout():
    # Stop floating and drop the object with physics
    is_floating = false
    activate_physics()

func activate_physics():
    # Enable physics and allow the object to fall naturally
    freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
    sleeping = false
    freeze = false


func set_properties(float_position, hover_amplitude, hover_speed, floating_duration, drop_duration):
    self.float_position = float_position
    self.hover_amplitude = hover_amplitude
    self.hover_speed = hover_speed
    self.floating_duration = floating_duration
    self.drop_duration = drop_duration

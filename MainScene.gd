extends Node3D

@onready var present_manager = $PresentManager
@onready var network_manager = $NetworkManager
@export var poll_presents : bool = true


func _ready():
    
    network_manager.connect("present_fetched", present_manager.update_present)

    if poll_presents:
        network_manager.start_fetching()

func _process(_delta):
    # Allow manual present spawning for testing
    if Input.is_action_just_pressed("ui_accept"):

        var image: Image = Image.new()
        var image_path = "res://image.png"  # Set your image path here
        var error = image.load(image_path)
        # Check for errors
        if error == OK:
            print("Image loaded successfully!")

        present_manager.spawn_present(image)       
            
           
           

    

extends Node3D

@onready var present_manager = $PresentManager
@onready var network_manager = $NetworkManager


func _ready():
    
    network_manager.connect("present_fetched", present_manager.update_present)
    network_manager.start_fetching()

func _process(_delta):
    # Allow manual present spawning for testing
    if Input.is_action_just_pressed("ui_accept"):
        present_manager.spawn_present()

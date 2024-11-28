extends Node3D

@onready var present_manager = $PresentManager
@onready var network_manager = $NetworkManager
@onready var notification_manager = $NotificationManager
@export var poll_presents : bool = true


func _ready():
	
	network_manager.connect("present_fetched", present_manager.update_present)

	if poll_presents:
		network_manager.start_fetching()

func _process(_delta):
	
	if Input.is_action_just_pressed("KeyPress - K"):
		var image: Image = Image.new()
		var image_path = "res://image.png"
		var error = image.load(image_path)
		# Check for errors
		if error == OK:
			print("Image loaded successfully!")

			present_manager.spawn_present(image)       

	if Input.is_action_just_pressed("KeyPress - L"):
		
		notification_manager.show_notification("Test")
		network_manager.toggleFetch()
		
		   


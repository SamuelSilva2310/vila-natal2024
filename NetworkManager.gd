extends Node


@onready var notification_manager : Node = get_node("../NotificationManager")
signal present_fetched(data)
@export var endpoint: String = "http://127.0.0.1:8080/fetch"
@export var polling_interval: float = 5.0

var timer: Timer

func _ready():
	# Create and configure a timer for periodic fetching
	timer = Timer.new()
	timer.wait_time = polling_interval
	timer.one_shot = false
	add_child(timer)
	timer.connect("timeout", self._on_timer_timeout)
	
	

	print("[INFO] Fetching setup complete. Endpoint: ", endpoint, ", Polling Interval: ", polling_interval)

# Start periodic fetching
func start_fetching():
	#print(notification_manager)
	if not timer.is_stopped():
		print("[WARNING] Fetching already started.")
		return
	print("[INFO] Starting polling...")
	notification_manager.show_notification("AutoFetch - On")
	timer.start()


func stop_fetching():
	if timer.is_stopped():
		print("[WARNING] Fetching already stopped.")
		return
	print("[INFO] Stop polling...")
	notification_manager.show_notification("AutoFetch - Off")
	timer.stop()

func isFetching():

	if timer.is_stopped():
		return false
	
	return true

func toggleFetch():
	if isFetching():
		stop_fetching()
	else:
		start_fetching()

# Timer timeout callback to fetch present
func _on_timer_timeout():
	print("[INFO] Timer triggered. Initiating data fetch...")
	fetch_present()

# Fetch present data from the API
func fetch_present():
	print("[INFO] Fetching data from endpoint: ", endpoint)
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)

	var error = http_request.request(endpoint)
	if error != OK:
		print("[ERROR] HTTP request failed to start. Error Code: ", error)
		push_error("An error occurred in the HTTP request.")
		http_request.queue_free()  # Cleanup
	else:
		print("[INFO] HTTP request initiated successfully.")

# Handle the HTTP request completion
func _http_request_completed(result: int, response_code: int, headers: Array, body: PackedByteArray):
	print("[INFO] HTTP Request completed. Response Code: ", response_code)

	# Cleanup HTTPRequest instance
	var http_request = get_child(get_child_count() - 1) as HTTPRequest
	if http_request:
		http_request.queue_free()
	
	# Handle response codes
	match response_code:
		200:
			var image = load_image(headers, body)
			if image:
				emit_signal("present_fetched", image)
			else:
				print("[ERROR] Failed to load image from response.")
		204:
			print("[INFO] No image to be fetched")
		400:
			print("[ERROR] Bad Request: The server could not understand the request.")
		401:
			print("[ERROR] Unauthorized: Check API permissions or authentication.")
		403:
			print("[ERROR] Forbidden: The server refused the request.")
		404:
			print("[ERROR] Not Found: Endpoint is incorrect or resource is missing.")
		500:
			print("[ERROR] Internal Server Error: Something went wrong on the server.")
		_:
			print("[WARNING] Unexpected response code received: ", response_code)

# Parse and load the image from the response body
func load_image(headers, image_buffer):
	var image = Image.new()
	var content_type = get_header_value(headers, "Content-Type")
	print("[INFO] Content-Type header: ", content_type)

	var error: int
	if content_type == "image/png":
		error = image.load_png_from_buffer(image_buffer)
	elif content_type == "image/jpeg":
		error = image.load_jpg_from_buffer(image_buffer)
	else:
		print("[ERROR] Unsupported Content-Type or failed to detect format: ", content_type)
		return null

	if error != OK:
		print("[ERROR] Failed to parse image buffer. Error: ", error)
		return null

	var orientation = get_header_value(headers, "X-ImageOrientation-EXIF")
	print("[INFO] X-ImageOrientation-EXIF header: ", orientation)
	image.set_meta("orientation", orientation)
	return image

# Helper function to extract a specific header value
func get_header_value(headers: Array, header_name: String) -> String:
	for header in headers:
		if header.to_lower().begins_with(header_name.to_lower() + ":"):
			return header.substr(header_name.length() + 1).strip_edges()
	return ""

# Error handling utilities
func push_error(message: String):
	# Log and notify the error (can integrate with an error reporting system if needed)
	print("[CRITICAL ERROR] ", message)

extends Node

signal present_fetched(data)

@export var endpoint: String = "https://jsonplaceholder.typicode.com/todos/1"
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
    if not timer.is_stopped():
        print("[WARNING] Fetching already started.")
        return
    print("[INFO] Starting polling...")
    timer.start()

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
    
    if response_code == 200:
        # Parse the response body
        var body_string = body.get_string_from_utf8()
        var json = JSON.new()
        var parse_result = json.parse(body_string)
        if parse_result == OK:
            var data = json.get_data()
            emit_signal("present_fetched", data)
            #print("[INFO] Data fetched and parsed successfully: ", data)
        else:
            print("[ERROR] Failed to parse JSON. Error: ", parse_result)
            print("[DEBUG] Response Body: ", body_string)
    else:
        print("[WARNING] HTTP request returned an unexpected response code: ", response_code)

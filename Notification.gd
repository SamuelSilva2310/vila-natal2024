extends CanvasLayer

# Reference to the Panel and Label
@onready var notification_panel = $NotificationPanel
@onready var notification_text = $NotificationPanel/NotificationText

@export var notification_duration = 1.0  # Seconds to display the notification
@export var fade_duration = 0.5  # Fade-out duration

func _ready():
    # Hide the notification panel by default
    self.visible = false

func show_notification(message: String):
    # Reset visibility and alpha
    self.visible = true
    notification_panel.modulate.a = 1.0

    # Set the notification message
    notification_text.text = message

    # Adjust the size of the panel to fit the text (if needed)
    # notification_panel.rect_min_size = Vector2(0, 0)  # Reset min size
    # notification_panel.rect_size = notification_text.get_minimum_size() + Vector2(20, 20)  # Add padding

    # Hide the notification after the duration
    await get_tree().create_timer(notification_duration).timeout
    fade_out_notification()

func fade_out_notification():
    var tween = create_tween()
    tween.tween_property(notification_panel, "modulate:a", 0.0, fade_duration)
    tween.set_trans(Tween.TRANS_LINEAR)
    tween.set_ease(Tween.EASE_IN)
    await tween.finished
    self.visible = false

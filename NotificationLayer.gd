extends CanvasLayer

@export var notification_duration = 3.0  # Seconds to display the notification
@export var fade_duration = 0.5  # Fade-out duration

# Reference to the Label
@onready var notification_label = $NotificationLabel

# Show the notification with a message
func show_notification(message: String):
    notification_label.text = message
    notification_label.visible = true
    notification_label.modulate.a = 1.0  # Reset transparency
    
    # Schedule hiding the notification after the duration
    await get_tree().create_timer(notification_duration).timeout
    fade_out_notification()

# Smoothly fade out the notification
func fade_out_notification():
    var tween = create_tween()
    tween.tween_property(notification_label, "modulate:a", 0.0, fade_duration)
    tween.set_trans(Tween.TRANS_LINEAR)
    tween.set_ease(Tween.EASE_IN)
    await tween.finished
    notification_label.visible = false

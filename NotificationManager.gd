extends Node


#@export var notification_scene: PackedScene = preload("res://Notification.tscn")




# Show the notification with a message
func show_notification(message: String):

	var notification_instance = $Notification
	print("NotificationManager message: %s" % message)
	
	#get_tree().root.add_child(notificationInstance)
	print("Adding notification %s" % notification_instance)
	notification_instance.show_notification(message)

	

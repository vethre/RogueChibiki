extends Node

## Local Notification Manager for Android
## Schedules "come back" notifications when player leaves the game

# Notification messages (Ukrainian and English based on locale)
const MESSAGES_UK := [
	"Чібіки чекають на тебе!",
	"Твоя колода сумує без тебе...",
	"Час для нового забігу!",
	"Нові пригоди чекають!",
	"Повертайся до бою!",
]

const MESSAGES_EN := [
	"Chibiki are waiting for you!",
	"Your deck misses you...",
	"Time for a new run!",
	"New adventures await!",
	"Return to battle!",
]

# Notification timing (in seconds)
const NOTIFY_AFTER_1_DAY := 86400      # 24 hours
const NOTIFY_AFTER_3_DAYS := 259200    # 72 hours
const NOTIFY_AFTER_7_DAYS := 604800    # 7 days

# Notification IDs
const NOTIFICATION_ID_1_DAY := 1001
const NOTIFICATION_ID_3_DAYS := 1002
const NOTIFICATION_ID_7_DAYS := 1003

var plugin: Object = null
var notifications_enabled := true

func _ready() -> void:
	# Try to get the Android Notification Scheduler Plugin from AssetLib
	if Engine.has_singleton("NotificationSchedulerPlugin"):
		plugin = Engine.get_singleton("NotificationSchedulerPlugin")
		print("[Notifications] NotificationSchedulerPlugin loaded!")
	else:
		print("[Notifications] NotificationSchedulerPlugin not found")
		print("[Notifications] Install from AssetLib: 'Android Notification Scheduler Plugin'")

	# Cancel any pending notifications when game starts
	cancel_all_notifications()

	# Connect to app lifecycle
	get_tree().root.connect("focus_exited", _on_app_background)
	get_tree().root.connect("focus_entered", _on_app_foreground)

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_WM_GO_BACK_REQUEST:
			# App is closing - schedule notifications
			schedule_comeback_notifications()
		NOTIFICATION_APPLICATION_PAUSED:
			# App went to background
			schedule_comeback_notifications()
		NOTIFICATION_APPLICATION_RESUMED:
			# App came back to foreground
			cancel_all_notifications()

func _on_app_background() -> void:
	schedule_comeback_notifications()

func _on_app_foreground() -> void:
	cancel_all_notifications()

func schedule_comeback_notifications() -> void:
	if not notifications_enabled or plugin == null:
		return

	var messages := get_localized_messages()

	# Schedule notification after 1 day
	schedule_notification(
		NOTIFICATION_ID_1_DAY,
		"Rogue Chibiki",
		messages[randi() % messages.size()],
		NOTIFY_AFTER_1_DAY
	)

	# Schedule notification after 3 days
	schedule_notification(
		NOTIFICATION_ID_3_DAYS,
		"Rogue Chibiki",
		messages[randi() % messages.size()],
		NOTIFY_AFTER_3_DAYS
	)

	# Schedule notification after 7 days
	schedule_notification(
		NOTIFICATION_ID_7_DAYS,
		"Rogue Chibiki",
		messages[randi() % messages.size()],
		NOTIFY_AFTER_7_DAYS
	)

	print("[Notifications] Scheduled comeback notifications")

func schedule_notification(id: int, title: String, message: String, delay_seconds: int) -> void:
	if plugin == null:
		return

	# NotificationSchedulerPlugin API
	if plugin.has_method("scheduleNotification"):
		plugin.scheduleNotification(id, title, message, delay_seconds)
	elif plugin.has_method("schedule"):
		plugin.schedule(id, title, message, delay_seconds)
	elif plugin.has_method("createNotification"):
		# Some plugins use interval in milliseconds
		plugin.createNotification(id, title, message, delay_seconds * 1000)
	else:
		push_warning("[Notifications] Unknown plugin API - check documentation")

func cancel_notification(id: int) -> void:
	if plugin == null:
		return

	if plugin.has_method("cancelNotification"):
		plugin.cancelNotification(id)
	elif plugin.has_method("cancel"):
		plugin.cancel(id)

func cancel_all_notifications() -> void:
	if plugin == null:
		return

	if plugin.has_method("cancelAllNotifications"):
		plugin.cancelAllNotifications()
	elif plugin.has_method("cancelAll"):
		plugin.cancelAll()
	else:
		# Cancel individually
		cancel_notification(NOTIFICATION_ID_1_DAY)
		cancel_notification(NOTIFICATION_ID_3_DAYS)
		cancel_notification(NOTIFICATION_ID_7_DAYS)

	print("[Notifications] Cancelled all pending notifications")

func get_localized_messages() -> Array:
	# Check system locale
	var locale := OS.get_locale()

	if locale.begins_with("uk") or locale.begins_with("UA"):
		return MESSAGES_UK
	elif locale.begins_with("ru") or locale.begins_with("RU"):
		return MESSAGES_UK  # Use Ukrainian for Russian locale too
	else:
		return MESSAGES_EN

func set_notifications_enabled(enabled: bool) -> void:
	notifications_enabled = enabled
	if not enabled:
		cancel_all_notifications()

	# Save preference
	if StatsManager:
		StatsManager.set_setting("notifications_enabled", enabled)

func is_notifications_enabled() -> bool:
	return notifications_enabled

func load_preferences() -> void:
	if StatsManager and StatsManager.has_method("get_setting"):
		notifications_enabled = StatsManager.get_setting("notifications_enabled", true)

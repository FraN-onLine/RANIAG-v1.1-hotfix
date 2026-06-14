extends Node2D

@onready var mobile_ui = $MobileUI
@onready var dash_button: TouchScreenButton = $MobileUI/TouchScreenButton

func _ready():
	var is_mobile := DisplayServer.is_touchscreen_available()
	mobile_ui.visible = is_mobile
	if is_mobile:
		call_deferred("_position_mobile_controls")

func _position_mobile_controls() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	dash_button.position = Vector2(viewport_size.x - 110.0, viewport_size.y - 110.0)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_SIZE_CHANGED and mobile_ui.visible:
		_position_mobile_controls()

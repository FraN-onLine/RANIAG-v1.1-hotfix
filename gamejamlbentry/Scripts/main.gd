extends Node2D

@onready var mobile_ui = $MobileUI
@onready var dash_button: TouchScreenButton = $MobileUI/TouchScreenButton

func _ready():
	var is_mobile := DisplayServer.is_touchscreen_available()
	mobile_ui.visible = is_mobile
	

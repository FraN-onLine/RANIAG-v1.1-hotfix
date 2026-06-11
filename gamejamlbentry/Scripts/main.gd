extends Node2D

@onready var mobile_ui = $MobileUI

func _ready():
	mobile_ui.visible = DisplayServer.is_touchscreen_available()

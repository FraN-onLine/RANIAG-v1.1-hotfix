extends Node2D

@onready var mobile_ui = $MobileUI

func _ready():
	mobile_ui.visible = OS.has_feature("mobile")

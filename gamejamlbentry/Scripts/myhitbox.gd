# myhitbox.gd
class_name myHitbox
extends Area2D

@export var damage := 10  # Fixed typo: was "damge"

func _init() -> void:
	collision_layer = 1
	collision_mask = 0

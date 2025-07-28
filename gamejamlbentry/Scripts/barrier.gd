extends StaticBody2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $CollisionShape2D/Sprite2D

func _process(_delta):
	if Global.BarriersActive:
		collision_shape.disabled = false
		if sprite:
			sprite.visible = true
	else:
		collision_shape.disabled = true
		if sprite:
			sprite.visible = false

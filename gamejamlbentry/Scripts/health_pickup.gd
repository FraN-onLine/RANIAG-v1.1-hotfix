extends Area2D

@export var health_amount: int = 15

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	print(body)
	if body.has_method("add_health"):
		$"../buffs".play()
		body.add_health(health_amount)
		queue_free()

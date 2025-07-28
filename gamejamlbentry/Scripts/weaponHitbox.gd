extends Area2D

var damage : float = 20

func _set_damage(setdamage):
	damage = setdamage

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)

extends Area2D

@export var multiplier := 2.0
@export var duration := 5.0

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body is Player:
		$"../buffs".play()
		body.apply_attack_buff(multiplier, duration)
		queue_free()  # Destroy pickup after use

extends Area2D

@export var speed: float = 200.0
var direction = Vector2.ZERO

func _ready():
	$CollisionShape2D.disabled = false

func _process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	print(body)
	if body.is_in_group("enemy"):
		body.take_damage(15)
		queue_free()

extends Area2D

@export var speed: float = 180.0
@export var turn_speed: float = 8.0 # Higher = curves faster
var target: Node2D = null
var direction: Vector2 = Vector2.RIGHT

func _ready():
	connect("area_entered", Callable(self, "_on_area_entered"))
	
	

func _process(delta):
	if target and is_instance_valid(target):
		var desired = (target.global_position - global_position).normalized()
		# Curve: interpolate direction toward desired direction
		direction = direction.lerp(desired, clamp(turn_speed * delta, 0, 1)).normalized()
	position += direction * speed * delta

func _on_area_entered(area):
	# Check if the area belongs to the player
	if area.get_parent().is_in_group("Player"):
		area.get_parent().take_damage(5)
		queue_free()

func set_target(t):
	target = t


func _on_body_entered(body: Node2D) -> void:
	queue_free()

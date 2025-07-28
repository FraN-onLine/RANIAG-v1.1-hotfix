extends Area2D

@export var speed: float = 180.0
var direction: Vector2 = Vector2.RIGHT

func _ready():
	connect("area_entered", Callable(self, "_on_area_entered"))

func _process(delta):
	position += direction.normalized() * speed * delta
	
	# Remove if out of player's camera view
	var player = get_tree().get_nodes_in_group("Player")
	if player.size() > 0 and player[0].camera:
		var camera = player[0].camera
		var rect = Rect2(camera.get_screen_center() - camera.get_viewport_rect().size / 2, camera.get_viewport_rect().size)
		if not rect.has_point(global_position):
			queue_free()

func _on_area_entered(area):
	if area.get_parent().is_in_group("Player"):
		area.get_parent().take_damage(12.5)
		queue_free()

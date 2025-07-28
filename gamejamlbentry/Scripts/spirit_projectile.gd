extends Area2D
var checkpoint_manager
@export var speed: float = 250.0
var direction = Vector2.ZERO

func _ready():
	connect("area_entered", Callable(self, "_on_area_entered"))
	checkpoint_manager = get_parent().get_node("CheckpointManager")

func _process(delta):
	if direction != Vector2.ZERO:
		position += direction.normalized() * speed * delta
		$AnimatedSprite2D.rotation = direction.angle()

	# Remove if out of player's camera view
	var player = get_tree().get_nodes_in_group("Player")
	if player.size() > 0 and player[0].camera:
		var camera = player[0].camera
		var rect = Rect2(camera.get_screen_center() - camera.get_viewport_rect().size / 2, camera.get_viewport_rect().size)
		if not rect.has_point(global_position):
			queue_free()

func _on_area_entered(area):
	# Check if the area belongs to the player
	if area.get_parent().is_in_group("Player"):
		area.get_parent().take_damage(10)
		queue_free()

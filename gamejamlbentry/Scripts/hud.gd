extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_hearts()
	GameState.hud = self

func load_hearts():
	# Make sure the heart UI elements exist
	if has_node("HeartsFull"):
		$HeartsFull.size.x = GameState.lives * 53
		
	else:
		print("Heart UI elements not found!")

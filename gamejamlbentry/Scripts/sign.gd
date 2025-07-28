# sign.gd
extends Node2D

@onready var interaction_area = $InteractionArea
@export var sign_text: String = "This is a sign!"

func _ready():
	# Set up the interaction area
	interaction_area.action_name = "read"
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	print("Sign says: " + sign_text)
	# You can also show a dialog box or UI panel here
	# For example:
	# DialogSystem.show_dialog(sign_text)
	await get_tree().create_timer(0.1).timeout  # Small delay

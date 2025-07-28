extends Area2D

@export var mob_scenes: Array[PackedScene] = []
@export var spawn_positions: Array[NodePath] = []

var triggered := false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	print("Entered by: ", body)
	if triggered:
		return
	if body.is_in_group("Player"):
		triggered = true
		set_deferred("monitoring", false)
		spawn_mobs()

func spawn_mobs():
	var count = min(mob_scenes.size(), spawn_positions.size(), 10)
	for i in range(count):
		var mob_scene = mob_scenes[i]
		var pos_path = spawn_positions[i]
		if mob_scene and has_node(pos_path):
			var mob = mob_scene.instantiate()
			mob.minimap_icon = "mob" # <-- Add this line
			mob.add_to_group("minimap_objects") # <-- And this line
			get_parent().add_child(mob)
			mob.global_position = get_node(pos_path).global_position
	Global.EnemiesToBeat = count

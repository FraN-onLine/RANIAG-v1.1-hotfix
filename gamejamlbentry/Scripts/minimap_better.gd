# minimap.gd
extends MarginContainer
@export var player: NodePath
@export var zoom = 6
@onready var grid: TextureRect = $MarginContainer/Grid
@onready var player_marker: AnimatedSprite2D = $MarginContainer/Grid/Player
@onready var enemy: Sprite2D = $MarginContainer/Grid/Enemy
@onready var alert: Sprite2D = $MarginContainer/Grid/Alert
@onready var boss: Sprite2D = $MarginContainer/Grid/boss
@onready var icons = {"mob": enemy, "alert": alert, "boss": boss}
var grid_scale
var markers = {}

func _ready() -> void:
	player_marker.position = grid.size / 2
	grid_scale = grid.size * zoom / get_viewport().get_visible_rect().size
	var minimap_objects = get_tree().get_nodes_in_group("minimap_objects")
	for item in minimap_objects:
		_add_minimap_marker(item)
	# Listen for new nodes added to the group
	get_tree().connect("node_added", Callable(self, "_on_node_added"))

func _on_node_added(node):
	if node.is_in_group("minimap_objects"):
		_add_minimap_marker(node)

func _add_minimap_marker(item):
	if item.has_method("get") and item.get("minimap_icon") in icons and not markers.has(item):
		var new_marker = icons[item.minimap_icon].duplicate()
		grid.add_child(new_marker)
		new_marker.show()
		markers[item] = new_marker

func _process(delta: float) -> void:
	if !player:
		return
	var player_node = get_node(player)
	if !player_node:
		return
	
	player_marker.position = grid.size / 2
	
	# Create a list of items to remove (invalid objects)
	var items_to_remove = []
	
	for item in markers:
		# Check if the item is still valid before accessing its properties
		if !is_instance_valid(item):
			items_to_remove.append(item)
			continue
			
		var relative_pos = item.position - player_node.position
		# Flip both axes to correct horizontal and vertical flipping
		relative_pos.x = -relative_pos.x
		relative_pos.y = -relative_pos.y
		var obj_pos = relative_pos * grid_scale + grid.size / 2
		obj_pos.x = clamp(obj_pos.x, 0, grid.size.x)
		obj_pos.y = clamp(obj_pos.y, 0, grid.size.y)
		markers[item].position = obj_pos
	
	# Remove invalid items and their markers
	for item in items_to_remove:
		if markers[item]:
			markers[item].queue_free()
		markers.erase(item)

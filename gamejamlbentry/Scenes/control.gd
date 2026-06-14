extends Control

@onready var knob: TextureRect = $Knob

var output := Vector2.ZERO

var _active := false
var _pointer_id := -1

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_STOP
	knob.mouse_filter = MOUSE_FILTER_IGNORE
	if has_node("Base"):
		$Base.mouse_filter = MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(200, 200)
	call_deferred("_center_knob")

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and not _active:
		_center_knob()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_pointer(event.pressed, event.position, event.index)
	elif event is InputEventScreenDrag:
		if _active and event.index == _pointer_id:
			_move_knob(event.position)
			accept_event()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_pointer(event.pressed, event.position, -1)
	elif event is InputEventMouseMotion and _active and _pointer_id == -1:
		_move_knob(event.position)
		accept_event()

func _handle_pointer(pressed: bool, local_pos: Vector2, pointer_id: int) -> void:
	if pressed:
		_active = true
		_pointer_id = pointer_id
		_move_knob(local_pos)
		accept_event()
	elif _active and pointer_id == _pointer_id:
		_reset()
		accept_event()

func _center() -> Vector2:
	return size * 0.5

func _max_radius() -> float:
	return maxf(minf(size.x, size.y) * 0.42, 30.0)

func _move_knob(local_pos: Vector2) -> void:
	var center := _center()
	var offset := local_pos - center
	var max_radius := _max_radius()
	if offset.length() > max_radius:
		offset = offset.normalized() * max_radius
	knob.position = center + offset - knob.size * 0.5
	output = offset / max_radius if max_radius > 0.0 else Vector2.ZERO

func _reset() -> void:
	_active = false
	_pointer_id = -1
	output = Vector2.ZERO
	_center_knob()

func _center_knob() -> void:
	if is_instance_valid(knob):
		knob.position = _center() - knob.size * 0.5

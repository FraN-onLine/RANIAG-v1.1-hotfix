extends Control

@onready var knob: TextureRect = $Knob

var output := Vector2.ZERO

var _dragging := false
var _pointer_index := -1

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_STOP
	knob.mouse_filter = MOUSE_FILTER_IGNORE
	_center_knob()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and not _dragging:
		_center_knob()

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return

	if event is InputEventScreenTouch:
		_handle_press(event.pressed, event.position, event.index)
	elif event is InputEventScreenDrag:
		if _dragging and event.index == _pointer_index:
			_handle_drag(event.position)
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_press(event.pressed, event.position, -1)
	elif event is InputEventMouseMotion and _dragging and _pointer_index == -1:
		_handle_drag(event.position)
		get_viewport().set_input_as_handled()

func _handle_press(pressed: bool, screen_pos: Vector2, index: int) -> void:
	if pressed:
		if not _is_inside(screen_pos):
			return
		_dragging = true
		_pointer_index = index
		_handle_drag(screen_pos)
		get_viewport().set_input_as_handled()
	elif _dragging and index == _pointer_index:
		_reset()
		get_viewport().set_input_as_handled()

func _handle_drag(screen_pos: Vector2) -> void:
	var local_pos := get_global_transform().affine_inverse() * screen_pos
	_apply_stick(local_pos)

func _is_inside(screen_pos: Vector2) -> bool:
	var local_pos := get_global_transform().affine_inverse() * screen_pos
	return get_rect().has_point(local_pos)

func _center() -> Vector2:
	return size * 0.5

func _max_distance() -> float:
	return maxf(min(size.x, size.y) * 0.5 - knob.size.x * 0.25, 24.0)

func _apply_stick(local_pos: Vector2) -> void:
	var center := _center()
	var offset := local_pos - center
	var max_dist := _max_distance()
	if offset.length() > max_dist:
		offset = offset.normalized() * max_dist
	knob.position = center + offset - knob.size * 0.5
	output = offset / max_dist if max_dist > 0.0 else Vector2.ZERO

func _reset() -> void:
	_dragging = false
	_pointer_index = -1
	_center_knob()
	output = Vector2.ZERO

func _center_knob() -> void:
	knob.position = _center() - knob.size * 0.5

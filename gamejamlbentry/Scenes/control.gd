extends Control

@onready var knob = $Knob

@export var max_distance := 50.0

var output := Vector2.ZERO
var touching := false
var touch_index := -1

func _gui_input(event):

	if event is InputEventScreenTouch:

		var local_pos = event.position - size / 2

		if event.pressed:

			# Only start controlling if touch began inside joystick area
			if local_pos.length() <= max_distance:
				touching = true
				touch_index = event.index

		elif event.index == touch_index:

			touching = false
			touch_index = -1

			knob.position = Vector2.ZERO
			output = Vector2.ZERO

	elif event is InputEventScreenDrag:

		if touching and event.index == touch_index:

			var pos = event.position - size / 2

			if pos.length() > max_distance:
				pos = pos.normalized() * max_distance

			knob.position = pos
			output = pos / max_distance

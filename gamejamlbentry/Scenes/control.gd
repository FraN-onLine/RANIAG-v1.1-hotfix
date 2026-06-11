extends Control

@onready var knob = $Knob

@export var max_distance := 50.0

var output := Vector2.ZERO
var touching := false

func _gui_input(event):
	if event is InputEventScreenTouch:
		touching = event.pressed

		if !touching:
			knob.position = Vector2.ZERO
			output = Vector2.ZERO

	elif event is InputEventScreenDrag and touching:
		var pos = event.position - size / 2

		if pos.length() > max_distance:
			pos = pos.normalized() * max_distance

		knob.position = pos
		output = pos / max_distance

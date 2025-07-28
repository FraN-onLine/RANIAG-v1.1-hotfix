extends Node

var EnemiesToBeat = 0
var BossDefeated = 0
var BarriersActive = false

func _process(delta: float) -> void:
	if EnemiesToBeat <= 0:
		BarriersActive = false
	else:
		BarriersActive = true
	
	if BossDefeated == 2:
		get_tree().change_scene_to_file("res://Scenes/YOUWIN.tscn")

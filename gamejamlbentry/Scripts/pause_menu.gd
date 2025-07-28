extends Control
func _ready():
	$AnimationPlayer.play("RESET")
func resume():
	get_tree().paused = false;
	$AnimationPlayer.play_backwards("blur");
	
func pause():
	get_tree().paused = true;
	$AnimationPlayer.play("blur");
	
func esc():
	if Input.is_action_just_pressed("escape") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("escape") and get_tree().paused:
		resume()
	


func _on_resume_pressed() -> void:
	resume() 


func _on_restart_pressed() -> void:
	resume()
	get_tree().reload_current_scene()
	


func _on_return_to_title_screen_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _process(delta):
	esc()

extends Area2D

var triggered = false

func _on_body_entered(body):
	if body is Player and triggered == false:
		triggered == true  
		$"../HUD/NarrativeLabel".bossfight()

extends Label

func _process(delta: float) -> void:
	$".".text = "Enemies To Defeat: " + str(Global.EnemiesToBeat)

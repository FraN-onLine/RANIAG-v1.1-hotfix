extends HSlider

@export var audio_bus_name: String = "All"
var audio_bus_id

func _ready():
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)
	print("Audio Bus ID:", audio_bus_id)
	
func _on_value_changed(slider_value: float) -> void:
	var normalized_value = (slider_value + 80) / 80
	var db = linear_to_db(normalized_value)
	AudioServer.set_bus_volume_db(audio_bus_id, slider_value)

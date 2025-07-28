extends Label

@onready var narrative_label = $"."

var narrative_texts = [
	"You wake up in a mysterious forest, unsure of how you got here...",
	"Spirits are rampant in this time of year, Do they wish for departure?",
	"You decided to venture further to investigate this case....",
	"(Left CLick to Attack, Use [SpaceBar] to Dash)",
	"Death doesnt seem to falter you, You feel more fragile, yet stronger",
	"Be the light to guide these spirits back home... Such is Raniag",
	"This is the last spirit you expect to see at the crossends...",
	"Yet it's making the other spirits rampant this season...",
	"(Target Lowerhalf to Subdue Upperhalf)"
]

func _ready():
	narrative_label.text = ""
	narrative_label.visible = false
	show_narrative_sequence()

func show_narrative_sequence():
	narrative_label.visible = true
	narrative_label.text = narrative_texts[0]
	await get_tree().create_timer(2.0).timeout
	narrative_label.visible = false
	await get_tree().create_timer(0.2).timeout # brief pause
	narrative_label.visible = true
	narrative_label.text = narrative_texts[1]
	await get_tree().create_timer(2.0).timeout
	narrative_label.visible = false
	narrative_label.visible = true
	narrative_label.text = narrative_texts[2]
	await get_tree().create_timer(2.0).timeout
	narrative_label.visible = false
	narrative_label.visible = true
	narrative_label.text = narrative_texts[3]
	await get_tree().create_timer(2.0).timeout
	narrative_label.visible = false
	
func firstdeath():
	narrative_label.visible = true
	narrative_label.text = narrative_texts[4]
	await get_tree().create_timer(2.5).timeout
	narrative_label.visible = false

func secondeath():
	narrative_label.visible = true
	narrative_label.text = narrative_texts[5]
	await get_tree().create_timer(2.5).timeout
	narrative_label.visible = false

func bossfight():
	narrative_label.visible = true
	narrative_label.text = narrative_texts[6]
	await get_tree().create_timer(2.5).timeout
	narrative_label.visible = false
	narrative_label.visible = true
	narrative_label.text = narrative_texts[7]
	await get_tree().create_timer(2.0).timeout
	narrative_label.visible = false
	narrative_label.visible = true
	narrative_label.text = narrative_texts[8]
	await get_tree().create_timer(2.0).timeout
	narrative_label.visible = false

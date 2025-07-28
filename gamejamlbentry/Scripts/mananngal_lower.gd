extends CharacterBody2D

class_name MananngalLower

@export var pulse_visible_time: float = 1.5
@export var pulse_invisible_time: float = 2.0
@export var heal_amount: float = 50.0
@export var heal_interval: float = 2.0
@export var boss_search_radius: float = 400.0
@export var small_mob_scene: PackedScene
@export var summon_interval: float = 10.0

@onready var healthbar: ProgressBar = $Healthbar
var max_health = 300.0
var health = 300.0
var pulse_timer = 0.0
var heal_timer = 0.0
var is_visible = true
var summon_timer = 0.0
var minimap_icon = "boss"
func _ready():
	health = max_health
	healthbar.init_health(max_health)
	pulse_timer = pulse_visible_time
	heal_timer = heal_interval
	visible = true
	summon_timer = 0.0

func _process(delta):
	if not GameState.player_alive:
		velocity = Vector2.ZERO
		return

	# Always increment summon_timer and check for mob summoning
	summon_timer += delta
	if summon_timer >= summon_interval:
		summon_small_mob()
		summon_timer = 0.0

	if is_visible:
		pulse_timer -= delta
		heal_timer -= delta
		if heal_timer <= 0.0:
			heal_boss()
			heal_timer = heal_interval
		if pulse_timer <= 0.0:
			# Become invisible and start summoning
			is_visible = false
			visible = false
			pulse_timer = pulse_invisible_time
			# No longer reset summon_timer here
	else:
		pulse_timer -= delta
		if pulse_timer <= 0.0:
			# Become visible and teleport very close to boss
			is_visible = true
			visible = true
			pulse_timer = pulse_visible_time
			teleport_very_close_to_boss()

func heal_boss():
	var bosses = get_tree().get_nodes_in_group("MananBoss")
	for boss in bosses:
		if boss and boss.health < boss.max_health:
			boss.health = min(boss.max_health, boss.health + heal_amount)
			boss.healthbar._set_health(boss.health)
			boss.emit_signal("healthChanged", boss.health)

func teleport_very_close_to_boss():
	var bosses = get_tree().get_nodes_in_group("Boss")
	if bosses.size() > 0:
		var boss = bosses[randi() % bosses.size()]
		var angle = randf() * TAU
		var dist = 10 + randf() * 10 # 10 to 20 pixels
		global_position = boss.global_position + Vector2.RIGHT.rotated(angle) * dist

func summon_small_mob():
	if small_mob_scene:
		var mob = small_mob_scene.instantiate()
		get_parent().add_child(mob)
		mob.global_position = global_position

func take_damage(damage):
	health -= damage
	healthbar._set_health(health)
	emit_signal("healthChanged", health)
	if health <= 0:
		health = 0
		$AnimatedSprite2D.visible = false
		healthbar.visible = false
		print("Unit is dead!")
		Global.BossDefeated += 1
		self.queue_free()

extends CharacterBody2D

class_name mananngal_upper

signal healthChanged

@onready var healthbar: ProgressBar = $Healthbar
@export var speed: float = 60.0
@export var hover_radius: float = 120.0
@export var shoot_cooldown: float = 2.0
@export var projectile_scene: PackedScene
var minimap_icon = "boss"
var max_health = 500
var health = 500
var shoot_timer = 0.0
var hover_angle = 0.0
var hover_speed = 1.0 # radians per second

var barrage_timer = 0.0
var barrage_interval = 5.0
var barrage_shots = 0
var barrage_max_shots = 5
var barrage_shot_delay = 0.12
var barrage_shot_timer = 0.0
var barrage_direction = Vector2.ZERO

func _ready():
	health = max_health
	healthbar.init_health(max_health)
	barrage_timer = barrage_interval

func _process(delta):
	if not GameState.player_alive:
		velocity = Vector2.ZERO
		return
	
	var player = get_nearest_player()
	if player:
		# Orbit/hover around the player
		hover_angle += hover_speed * delta
		var offset = Vector2.RIGHT.rotated(hover_angle) * hover_radius
		var target_pos = player.global_position + offset
		var to_target = target_pos - global_position
		if to_target.length() > 4:
			velocity = to_target.normalized() * speed
		else:
			velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	# Regular 8-way shooting
	shoot_timer -= delta
	if shoot_timer <= 0.0:
		shoot_bullets()
		shoot_timer = shoot_cooldown

	# Barrage logic
	barrage_timer -= delta
	if barrage_timer <= 0.0 and barrage_shots == 0:
		# Start barrage
		player = get_nearest_player()
		if player:
			barrage_direction = (player.global_position - global_position).normalized()
		else:
			barrage_direction = Vector2.RIGHT
		barrage_shots = barrage_max_shots
		barrage_shot_timer = 0.0
		barrage_timer = barrage_interval

	if barrage_shots > 0:
		barrage_shot_timer -= delta
		if barrage_shot_timer <= 0.0:
			shoot_barrage_bullet(barrage_direction)
			barrage_shots -= 1
			barrage_shot_timer = barrage_shot_delay

func shoot_bullets():
	if projectile_scene:
		$"../man".play()
		for i in range(8):
			var angle = PI * 0.25 * i # 0, 45, 90, ..., 315 degrees
			var dir = Vector2.RIGHT.rotated(angle)
			var bullet = projectile_scene.instantiate()
			get_parent().add_child(bullet)
			bullet.global_position = global_position
			bullet.direction = dir

func shoot_barrage_bullet(dir):
	if projectile_scene:
		var bullet = projectile_scene.instantiate()
		get_parent().add_child(bullet)
		bullet.global_position = global_position
		bullet.direction = dir

func get_nearest_player():
	var nearest = null
	var min_dist = INF
	for player in get_tree().get_nodes_in_group("Player"):
		var dist = player.global_position.distance_to(global_position)
		if dist < min_dist:
			min_dist = dist
			nearest = player
	return nearest

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

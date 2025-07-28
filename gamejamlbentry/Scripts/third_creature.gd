extends CharacterBody2D
class_name third_creature
signal healthChanged
@onready var healthbar: ProgressBar = $Healthbar
@export var speed: float = 30.0
@export var detection_radius: float = 100.0
@export var shoot_radius: float = 90.0
@export var shoot_cooldown: float = 1.5
@export var projectile_scene: PackedScene
@export var min_distance: float = 80.0
var minimap_icon = "mob"
var max_health = 30
var health = 25
var roam_direction = Vector2.RIGHT
var roam_timer = 0.0
var shoot_timer = 0.0
func _ready():
	health = max_health
	healthbar.init_health(max_health)
func _process(delta):
	if not GameState.player_alive:
		velocity = Vector2.ZERO
		return
	shoot_timer -= delta
	var player = get_nearest_player()
	
	if player:
		var to_player = player.global_position - global_position
		var distance = to_player.length()
		if distance < detection_radius:
			# Maintain minimum distance
			if distance > min_distance:
				velocity = to_player.normalized() * speed
			elif distance < min_distance * 0.8:
				velocity = -to_player.normalized() * speed # Move away if too close
			else:
				velocity = Vector2.ZERO
			# Flip sprite based on direction to player
			if abs(to_player.x) > 0.1:
				$AnimatedSprite2D.flip_h = to_player.x > 0
			# Shoot two homing missiles if in range
			if distance < shoot_radius and shoot_timer <= 0.0:
				shoot_homing_missiles(player)
				shoot_timer = shoot_cooldown
		else:
			roam(delta)
	else:
		roam(delta)
	move_and_slide()
func get_nearest_player():
	var nearest = null
	var min_dist = INF
	for player in get_tree().get_nodes_in_group("Player"):
		var dist = player.global_position.distance_to(global_position)
		if dist < min_dist:
			min_dist = dist
			nearest = player
	return nearest
func roam(delta):
	$AnimatedSprite2D.play("idle")
	roam_timer -= delta
	if roam_timer <= 0:
		roam_direction = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
		roam_timer = randf() * 2 + 1
	velocity = roam_direction * speed * 0.5
	# Flip sprite when roaming
	if abs(roam_direction.x) > 0.1:
		$AnimatedSprite2D.flip_h = roam_direction.x > 0
func shoot_homing_missiles(target):
	$AnimatedSprite2D.play("attack")
	if projectile_scene:
		$"../third".play()
		for i in range(2):
			var missile = projectile_scene.instantiate()
			get_parent().add_child(missile)
			var angle_offset = deg_to_rad(-10 + 20 * i) # -10 and +10 degrees
			var dir = (target.global_position - global_position).normalized().rotated(angle_offset)
			var spawn_offset = dir * 8
			missile.global_position = global_position + spawn_offset
			missile.direction = dir
			missile.target = target
func take_damage(damage):
	health -= damage
	healthbar._set_health(health)
	emit_signal("healthChanged", health)
	if health <= 0:
		health = 0
		$AnimatedSprite2D.visible = false
		healthbar.visible = false
		print("Unit is dead!")
		Global.EnemiesToBeat -= 1
		self.queue_free()

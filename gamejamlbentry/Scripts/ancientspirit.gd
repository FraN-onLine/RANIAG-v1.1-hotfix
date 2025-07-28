extends CharacterBody2D
class_name Ancient_Spirit

signal healthChanged

@onready var healthbar: ProgressBar = $Healthbar
@onready var damage_area: Area2D = $Hitbox  # Make sure this matches your node structure
@export var speed: float = 34.0
@export var detection_radius: float = 60.0

var minimap_icon = "mob"
var max_health = 55
var health = 55
var roam_direction = Vector2.RIGHT
var roam_timer = 0.0
var run_away_timer = 0.0
var run_away_direction = Vector2.ZERO

func _ready():
	health = max_health
	healthbar.init_health(max_health)
	
	# Connect the damage area signal if it exists
	if damage_area:
		damage_area.body_entered.connect(_on_damage_area_body_entered)
	else:
		print("Warning: No damage area found for Ancient Spirit")

func _process(delta):
	if not GameState.player_alive:
		velocity = Vector2.ZERO
		return
	if run_away_timer > 0:
		run_away_timer -= delta
		velocity = run_away_direction * speed
		# Flip sprite based on run away direction
		if abs(run_away_direction.x) > 0.1:
			$AnimatedSprite2D.flip_h = run_away_direction.x > 0
	else:
		var player = get_nearest_player()
		if player:
			var to_player = player.global_position - global_position
			var distance = to_player.length()
			
			if distance < detection_radius:
				velocity = to_player.normalized() * speed
				# Flip sprite based on direction to player
				if abs(to_player.x) > 0.1:
					$AnimatedSprite2D.flip_h = to_player.x > 0
			else:
				roam(delta)
		else:
			roam(delta)
	
	move_and_slide()

func get_nearest_player():
	var nearest = null
	var min_dist = INF
	for player in get_tree().get_nodes_in_group("Player"):
		if is_instance_valid(player):
			var dist = player.global_position.distance_to(global_position)
			if dist < min_dist:
				min_dist = dist
				nearest = player
	return nearest

func roam(delta):
	roam_timer -= delta
	if roam_timer <= 0:
		roam_direction = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
		roam_timer = randf() * 2 + 1
	
	velocity = roam_direction * speed * 0.5
	# Flip sprite when roaming
	if abs(roam_direction.x) > 0.1:
		$AnimatedSprite2D.flip_h = roam_direction.x > 0

func take_damage(damage):
	health -= damage
	healthbar._set_health(health)
	emit_signal("healthChanged", health)
	
	if health <= 0:
		health = 0
		$AnimatedSprite2D.visible = false
		healthbar.visible = false
		print("Ancient Spirit is dead!")
		Global.EnemiesToBeat -= 1
		queue_free()

func _on_damage_area_body_entered(body: Node2D) -> void:
	print("Damage area entered by: ", body.name)
	if body.is_in_group("Player") and body.has_method("take_damage"):
		$"../spirit".play()
		body.take_damage(7.5)
		# Run away from player
		var to_player = body.global_position - global_position
		run_away_direction = -to_player.normalized()
		run_away_timer = 0.6
		print("Player took damage from Ancient Spirit")

extends CharacterBody2D

class_name Player

signal healthChanged

@onready var healthbar: ProgressBar = get_tree().get_first_node_in_group("healthbar")
@onready var weapon_hitbox: Area2D = $Hand/Node2D/AnimatedSprite2D/weaponHitbox
@export var base_speed: float = 200.0
@export var camera: Camera2D
@onready var sword_slash: AudioStreamPlayer2D = $SwordSlash

var max_health = 100
var health = 100
var attacking = false
var is_dead = false
var stage = 1
var death_position: Vector2
@export var base_attack: float = 6.5
var speed: float = base_speed
var attack_damage: int = base_attack
var is_invulnerable: bool = false

var is_speed_buffed: bool = false
var is_attack_buffed: bool = false
var multiplier = 1
var is_dashing = false
var dash_speed = 500.0
var dash_time = 0.18
var dash_timer = 0.0
var dash_direction = Vector2.ZERO
var dash_charges := 2
var recharge_in_progress := false
var dash_recharge_timer := 0.0
var max_dash_charges := 2

# Dash cooldown variables
var dash_cooldown := 0.7
var dash_cooldown_timer := 0.0
var can_dash := true

# Revive animation control
var revive_played = false
var time_since_death = 0.0

func _ready():
	health = max_health
	is_dead = false
	GameState.player_alive = true
	call_deferred("setup_healthbar")

	if is_instance_valid(weapon_hitbox):
		weapon_hitbox.monitoring = false
	else:
		print("Weapon hitbox not found! Check node path.")

func setup_healthbar():
	if not is_instance_valid(healthbar):
		healthbar = get_tree().get_first_node_in_group("healthbar")
		if not is_instance_valid(healthbar):
			healthbar = get_tree().current_scene.find_child("Healthbar", true, false)

	if is_instance_valid(healthbar):
		healthbar.init_health(max_health)
	else:
		print("Healthbar not found! Make sure it's in a CanvasLayer and added to 'healthbar' group.")

func _process(delta):
	if recharge_in_progress:
		dash_recharge_timer -= delta
		if dash_recharge_timer <= 0.0:
			dash_charges = max_dash_charges
			recharge_in_progress = false
			print("Dash charges replenished.")
	# Set weapon damage
	if has_node("Hand/Node2D/AnimatedSprite2D/weaponHitbox"):
		$Hand/Node2D/AnimatedSprite2D/weaponHitbox._set_damage(base_attack * multiplier)

	# Dash cooldown timer
	if not can_dash:
		dash_cooldown_timer -= delta
		if dash_cooldown_timer <= 0.0:
			can_dash = true

	if is_dead:
		if not revive_played:
			time_since_death += delta
			if time_since_death >= 2.5:
				play_revive_animation()
		return

	update_animation()

# Handle dashing movement
	if is_dashing:
		var collision = move_and_collide(dash_direction * dash_speed * delta)

		if collision or dash_timer <= 0:
			is_dashing = false
			is_invulnerable = false  # ← Disable invulnerability when dash ends

			if is_instance_valid(weapon_hitbox):
				weapon_hitbox.monitoring = false
		else:
			dash_timer -= delta

		return

	# Normal movement
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	input_vector = input_vector.normalized() * speed if input_vector.length() > 0 else Vector2.ZERO
	velocity = input_vector
	move_and_slide()

	if input_vector.x != 0:
		$AnimatedSprite2D.flip_h = input_vector.x < 0

	# Aim hand toward mouse
	var arrow = $Hand
	if arrow:
		var mouse_pos = get_global_mouse_position()
		var angle = (mouse_pos - global_position).angle()
		arrow.rotation = angle
		arrow.position = Vector2.RIGHT.rotated(angle) * 3.5

	if camera:
		camera.position = position

func update_animation():
	if is_dashing:
		$AnimatedSprite2D.play("dash%d" % stage)
	elif velocity.length() > 0:
		$AnimatedSprite2D.play("run%d" % stage)
	else:
		$AnimatedSprite2D.play("idle%d" % stage)

func play_revive_animation():
	$AnimatedSprite2D.play("revive%d" % stage)
	revive_played = true

func _input(event):
	if is_dead:
		return

	# Separated Basic Attack
	if event.is_action_pressed("basic_attack") and not is_dashing:
		attacking = true
		if is_instance_valid(weapon_hitbox):
			weapon_hitbox.monitoring = true
		$Hand/Node2D/AnimatedSprite2D.play("attack")
		#sword_slash.play()
	elif event.is_action_released("basic_attack"):
		attacking = false
		if is_instance_valid(weapon_hitbox):
			weapon_hitbox.monitoring = false

	# Separated Dash
	if event.is_action_pressed("dash") and dash_charges > 0:
		var input_vector = Vector2(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
		).normalized()

		if input_vector != Vector2.ZERO:
			is_dashing = true
			dash_timer = dash_time
			dash_direction = input_vector
			$AnimatedSprite2D.play("dash%d" % stage)
			$AnimatedSprite2D.flip_h = dash_direction.x < 0

			is_invulnerable = true
			dash_charges -= 1
			print("Dash used. Remaining charges:", dash_charges)

			if dash_charges == 0 and not recharge_in_progress:
				recharge_in_progress = true
				dash_recharge_timer = dash_cooldown
			

func set_damage(amount):
	if has_node("Hand/Node2D/Sprite2D/Area2D"):
		$Hand/Node2D/Sprite2D/Area2D.damage = amount

func take_damage(damage):
	if is_dead or is_invulnerable:
		return

	health -= damage
	if is_instance_valid(healthbar):
		healthbar._set_health(health)
	emit_signal("healthChanged", health)
	if health <= 0:
		health = 0
		is_dead = true
		GameState.player_alive = false
		death_position = position

		$AnimatedSprite2D.play("death%d" % stage)
		revive_played = false
		time_since_death = 0.0

		if is_instance_valid(healthbar):
			healthbar.hide()
		if is_instance_valid(weapon_hitbox):
			weapon_hitbox.monitoring = false

		print("Unit is dead!")

		GameState.lose_life()

		stage += 1
		max_health -= 10
		multiplier += 0.1
		
		if stage == 2:
			$"../HUD/NarrativeLabel".firstdeath()
		if stage == 3:
			$"../HUD/NarrativeLabel".secondeath()


		if is_instance_valid(healthbar):
			healthbar.init_health(max_health)

		await get_tree().create_timer(5.0).timeout

		if GameState.lives > 0 and stage <= 5:
			respawn()
		else:
			Global.EnemiesToBeat = 0
			get_tree().change_scene_to_file("res://Scenes/YouDIEDMOTHERFUCKA.tscn")
			
	if is_dead == false:
		$AnimatedSprite2D.modulate = Color(1, 0.2, 0.2)  # red tint
		await get_tree().create_timer(0.2).timeout
		$AnimatedSprite2D.modulate = Color(1, 1, 1)      # reset

func respawn():
	position = death_position
	health = max_health
	is_dead = false
	revive_played = false
	time_since_death = 0.0
	GameState.player_alive = true
	$AnimatedSprite2D.visible = true

	if is_instance_valid(healthbar):
		healthbar.show()
		healthbar._set_health(health)
		healthbar.visible = true

	emit_signal("healthChanged", health)

# -------------------------------
# Buff Functions (TEMPORARY)
# -------------------------------
func apply_speed_buff(multiplier: float, duration: float):
	if is_speed_buffed:
		return
	is_speed_buffed = true
	speed *= multiplier
	print("Speed buff applied! New speed:", speed)

	await get_tree().create_timer(duration).timeout
	speed = base_speed
	is_speed_buffed = false
	print("Speed buff ended. Speed reset to:", speed)

func apply_attack_buff(multiplier: float, duration: float):
	if is_attack_buffed:
		return
	is_attack_buffed = true
	attack_damage *= multiplier
	print("Attack buff applied! New damage:", attack_damage)

	await get_tree().create_timer(duration).timeout
	attack_damage = base_attack
	is_attack_buffed = false
	print("Attack buff ended. Damage reset to:", attack_damage)
	
func add_health(amount: int):
	if is_dead:
		return
	health = min(health + amount, max_health)
	if is_instance_valid(healthbar):
		healthbar._set_health(health)
	emit_signal("healthChanged", health)

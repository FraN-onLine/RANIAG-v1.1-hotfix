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
@export var base_attack: float = 6.6
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
var _attack_touch_index := -1

@onready var joystick = get_tree().get_first_node_in_group("joystick")
@onready var mobile_ui: CanvasLayer = get_node_or_null("../MobileUI")

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

	var move_direction := _get_movement_direction()
	velocity = move_direction * speed
	move_and_slide()

	if move_direction.x != 0:
		$AnimatedSprite2D.flip_h = move_direction.x < 0

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

func _get_movement_direction() -> Vector2:
	if _is_mobile_controls_active() and is_instance_valid(joystick):
		var joy_dir: Vector2 = joystick.output
		if joy_dir.length() > 0.01:
			return joy_dir.normalized()

	var input_vector := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	if input_vector.length() > 0.01:
		return input_vector.normalized()
	return Vector2.ZERO

func _is_mobile_controls_active() -> bool:
	return is_instance_valid(mobile_ui) and mobile_ui.visible

func _get_dash_direction() -> Vector2:
	var move_dir := _get_movement_direction()
	if move_dir != Vector2.ZERO:
		return move_dir
	return Vector2.LEFT if $AnimatedSprite2D.flip_h else Vector2.RIGHT

func _input(event):
	if is_dead:
		return

	if event.is_action_pressed("dash") and dash_charges > 0:
		var input_vector := _get_dash_direction()
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
		return

	if _is_event_over_ui(event):
		return

	if event.is_action_pressed("basic_attack") and not is_dashing:
		_start_attack()
	elif event.is_action_released("basic_attack"):
		_stop_attack()
	elif event is InputEventScreenTouch:
		if event.pressed and not is_dashing:
			_attack_touch_index = event.index
			_start_attack()
		elif event.index == _attack_touch_index:
			_attack_touch_index = -1
			_stop_attack()

func _start_attack() -> void:
	attacking = true
	if is_instance_valid(weapon_hitbox):
		weapon_hitbox.monitoring = true
	$Hand/Node2D/AnimatedSprite2D.play("attack")

func _stop_attack() -> void:
	attacking = false
	if is_instance_valid(weapon_hitbox):
		weapon_hitbox.monitoring = false

func _is_event_over_ui(event: InputEvent) -> bool:
	var screen_pos := _get_event_screen_position(event)
	if screen_pos == Vector2.INF:
		return false
	return _is_screen_position_over_ui(screen_pos)

func _get_event_screen_position(event: InputEvent) -> Vector2:
	if event is InputEventMouse:
		return event.position
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		return event.position
	return Vector2.INF

func _is_screen_position_over_ui(screen_pos: Vector2) -> bool:
	if _is_over_touch_screen_button(screen_pos):
		return true
	for layer_path in ["../MobileUI", "../HUD"]:
		var layer := get_node_or_null(layer_path)
		if layer == null or not layer.visible:
			continue
		if _control_tree_contains_point(layer, screen_pos):
			return true
	return false

func _is_over_touch_screen_button(screen_pos: Vector2) -> bool:
	var btn := get_node_or_null("../MobileUI/TouchScreenButton") as TouchScreenButton
	if btn == null or not btn.is_visible_in_tree():
		return false
	var local_pos := btn.get_global_transform().affine_inverse() * screen_pos
	if btn.shape is RectangleShape2D:
		var rect_shape := btn.shape as RectangleShape2D
		var half_size := rect_shape.size * 0.5
		return Rect2(-half_size, rect_shape.size).has_point(local_pos)
	return false

func _control_tree_contains_point(node: Node, screen_pos: Vector2) -> bool:
	if node is Control:
		var control := node as Control
		if control.visible and control.mouse_filter != Control.MOUSE_FILTER_IGNORE:
			if control.get_global_rect().has_point(screen_pos):
				return true
	for child in node.get_children():
		if _control_tree_contains_point(child, screen_pos):
			return true
	return false

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
		$Hand.visible = false
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
		$Hand.visible = true

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

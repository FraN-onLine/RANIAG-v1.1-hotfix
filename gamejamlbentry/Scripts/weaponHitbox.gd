extends Area2D

var damage : float = 20

# Knockback throttle/cooldown.
# While this cooldown is > 0 on an enemy, knockback won't be re-applied.
const KNOCKBACK_COOLDOWN_SECONDS := 0.5


# How strong the knockback should feel.
# Stage 1 should be very small, stage 5 medium.
# You can tweak these values later if needed.
@export var knockback_base: float = 100.5 # stage 1 scale
@export var knockback_per_stage: float = 30.0 # additional strength per stage above 1

func _set_damage(setdamage):
	damage = setdamage

func _get_attacker_stage() -> int:
	# weaponHitbox is under Player -> $Hand/Node2D/AnimatedSprite2D/weaponHitbox
	var attacker := get_parent()
	# walk up a few levels to find Player
	for _i in range(6):
		if attacker == null:
			break
		if attacker.has_method("take_damage") or ("stage" in attacker):
			# stage is a variable on Player.gd
			if attacker.stage:
				return attacker.stage
			if "stage" in attacker:
				return int(attacker.stage)
			break
		attacker = attacker.get_parent()
	return 1

func _on_body_entered(body):
	if not body.has_method("take_damage"):
		return

	# Prevent applying knockback repeatedly within a short time window.
	# (Damage can still happen every hit; knockback application is throttled.)
	var kb_cd = body.get("knockback_cooldown_time_left")
	if kb_cd != null and kb_cd > 0.0:
		body.take_damage(damage)
		return

	# Damage
	body.take_damage(damage)


	# Knockback based on player stage
	var stage: int = _get_attacker_stage()



	# Direction: push enemy away from the hitbox (roughly away from the player)
	var dir: Vector2 = body.global_position - global_position

	if dir.length() < 0.001:
		dir = Vector2.LEFT
	dir = dir.normalized()

	# Stage scaling: stage 1 = base, stage 5 = base + 4*per_stage
	var strength: float = knockback_base + max(stage - 1, 0) * knockback_per_stage


# Apply knockback based on enemy physics type.
	# IMPORTANT: do NOT teleport/offset positions (e.g. global_position += ...) because it bypasses collisions.
	# Instead, inject knockback via velocity/direction for ~0.3s and let the enemy's move_and_slide handle walls.
	# Also: skip knockback for bosses (they have special movement and should not be displaced).
	if body is CharacterBody2D:
		if body.is_in_group("Boss") or body.is_in_group("MananBoss"):
			return

		# Prefer knockback fields if the enemy implements them.
		# Use get() to avoid fragile 'in body' checks.
		var kb_time = body.get("knockback_time_left")
		if kb_time != null:
			body.knockback_dir = dir
			body.knockback_strength = strength
			body.knockback_time_left = 0.1
			# 0.5s cooldown so knockback isn't re-applied rapidly.
			body.knockback_cooldown_time_left = KNOCKBACK_COOLDOWN_SECONDS

			return


		# Fallback for existing enemies that don't have knockback fields:

		if "roam_direction" in body:
			body.roam_direction = dir
		if "velocity" in body:
			body.velocity = dir * strength


	elif body is RigidBody2D:
		# Keep rigidbody knockback as-is (physics will handle collisions).
		body.apply_impulse(Vector2.ZERO, dir * strength)

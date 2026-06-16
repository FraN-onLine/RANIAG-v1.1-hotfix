# Optional helper script (not required by scenes).
# Enemy scripts can implement knockback variables directly; see usage in weaponHitbox.gd.
extends Node

var knockback_dir: Vector2 = Vector2.ZERO
var knockback_time_left: float = 0.0
var knockback_cooldown_time_left: float = 0.0

var knockback_strength: float = 0.0

func apply_knockback(dir: Vector2, strength: float, duration: float = 0.3) -> void:
	knockback_dir = dir
	knockback_strength = strength
	knockback_time_left = duration


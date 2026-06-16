# TODO

## Knockback fix (don’t push enemies through walls)
- [ ] Update `gamejamlbentry/Scripts/weaponHitbox.gd` to remove position-based knockback (`body.global_position += ...`) for `CharacterBody2D`.
- [ ] Replace with collision-aware knockback: apply velocity (or use `move_and_collide`-style) instead of teleporting position.
- [ ] Avoid fighting enemy AI: if the enemy script overwrites velocity, set a knockback direction variable the enemy can respect (e.g. `knockback_direction`) for a short timer.
- [ ] Keep `RigidBody2D` knockback as-is.


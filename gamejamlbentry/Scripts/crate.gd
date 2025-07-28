extends CharacterBody2D

@onready var hitbox: Area2D = $Hitbox
@onready var animated_sprite_2d: AnimatedSprite2D = $Hitbox/AnimatedSprite2D
@onready var sprite_2d: Sprite2D = $Hitbox/Sprite2D

@export var atk_pickup_scene: PackedScene
@export var health_pickup_scene: PackedScene
@export var speed_pickup_scene: PackedScene
var minimap_icon = "alert"

var is_destroyed = false

func _ready():
	hitbox.body_entered.connect(_on_body_entered)
	hitbox.area_entered.connect(_on_area_entered)
	animated_sprite_2d.visible = false  # Hide explosion initially

func take_damage(_damage):
	if not is_destroyed:
		is_destroyed = true
		sprite_2d.visible = false
		animated_sprite_2d.visible = true
		animated_sprite_2d.play("explode")
		animated_sprite_2d.animation_finished.connect(_on_explosion_finished)

func _on_body_entered(body):
	if not is_destroyed:
		if body.is_in_group("weapon_hitbox"):
			print("Crate: Taking damage from weapon (body)")
			take_damage(body.damage)
		elif body.is_in_group("Player") and body.is_dashing:
			print("Crate: Taking damage from player dash")
			take_damage(999)

func _on_area_entered(area):
	if not is_destroyed:
		if area.is_in_group("weapon_hitbox"):
			print("Crate: Taking damage from weapon (area)")
			take_damage(area.damage)

func _on_explosion_finished():
	var roll = randi() % 5
	var pickup_instance = null
	if roll == 0 and atk_pickup_scene:
		pickup_instance = atk_pickup_scene.instantiate()
	elif roll == 1 and health_pickup_scene:
		pickup_instance = health_pickup_scene.instantiate()
	elif roll == 2 and speed_pickup_scene:
		pickup_instance = speed_pickup_scene.instantiate()
	
	if pickup_instance:
		get_parent().add_child(pickup_instance)
		pickup_instance.global_position = global_position

	queue_free()

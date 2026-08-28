extends CharacterBody2D

var move_speed := 50
var direction := 1  # 1 = 오른쪽, -1 = 왼쪽

var knockback_speed := 150
var knockback_time := 0.1
var knockback_timer := 0.0
var knockback_direction := 0

var hp_e = 3

@onready var anim_sprite = $AnimatedSprite2D
@onready var hitbox = $Hitbox  # Area2D

func _ready():
	add_to_group("enemies")
	hitbox.connect("body_entered", Callable(self, "_on_hitbox_body_entered"))

func _physics_process(delta):
	anim_sprite.scale.x = direction
	anim_sprite.play("default")

	if knockback_timer > 0:
		velocity.x = knockback_direction * knockback_speed
		knockback_timer -= delta
		move_and_slide()
		return

	# 바닥 감지
	if $GroundRayCast2D.is_colliding():
		velocity.x = direction * move_speed
	else:
		direction *= -1
		velocity.x = direction * move_speed

	# 충돌 감지
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()

		if collider.is_in_group("player"):
			# ★ 플레이어에게 데미지를 주고 방향 전환
			collider.take_damage(global_position)
			direction *= -1

		elif collider.is_in_group("enemies") or collider is TileMap:
			# ★ 벽 또는 다른 적과 충돌 시 방향 전환
			direction *= -1
	else:
		move_and_slide()

func _on_hitbox_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(global_position)
		self.direction *= -1

func take_damage(amount := 1):
	hp_e -= 1
	if hp_e <= 0:
		queue_free()

func apply_knockback(dir: int):
	knockback_direction = dir
	knockback_timer = knockback_time

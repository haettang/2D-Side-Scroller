extends Area2D

@export var lifetime := 0.5
var timer := 0.0
var already_hit := false
var direction := 1  # 플레이어가 넘겨주는 방향

@onready var sprite = $sword  # Sprite 노드 경로 확인 필요

func _ready():
	sprite.scale.x = direction

func _process(delta):
	timer += delta
	if timer >= lifetime:
		queue_free()
		return

	sprite.modulate.a = 1.0 - (timer / lifetime)

func _on_body_entered(body):
	var enemy = body
	if not body.is_in_group("enemies") and body.get_parent() and body.get_parent().is_in_group("enemies"):
		enemy = body.get_parent()

	if not enemy.is_in_group("enemies"):
		return

	if enemy.has_method("take_damage"):
		enemy.take_damage(7)

	if enemy.has_method("apply_knockback"):
		var knockback_dir = sign(enemy.global_position.x - global_position.x)
		if knockback_dir == 0:
			knockback_dir = 1
		enemy.apply_knockback(knockback_dir)

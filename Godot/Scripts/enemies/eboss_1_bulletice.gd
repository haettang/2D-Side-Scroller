extends Area2D

@onready var audioplayer = $AudioStreamPlayer2D
@onready var anim_sprite = $AnimatedSprite2D
@export var speed := 400
var direction := Vector2.ZERO
var has_bounced := false  # 1회만 튕기도록 추적

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	$VisibleOnScreenNotifier2D.connect("screen_exited", Callable(self, "queue_free"))
	audioplayer.stream = preload("res://sounds/WAV_Small_Spark_2/WAV_Small_Spark_2.wav")
	audioplayer.play()
	
func _physics_process(delta):
	position += direction * speed * delta
	anim_sprite.play("default")

func initialize(target_position: Vector2):
	direction = (target_position - global_position).normalized()
	rotation = direction.angle()

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(global_position)
		queue_free()
	elif body is TileMap or body is StaticBody2D:
		if not has_bounced:
			_bounce_off(body)
			has_bounced = true
		else:
			queue_free()

func _bounce_off(collider):
	# 벽의 표면 방향에 따라 반사되도록 처리
	# 여기서는 간단하게 x축 또는 y축 기준으로 반사
	# (충돌 방향이 정확히 감지되는 방식은 아니지만, 일반적인 벽 반사처럼 작동함)

	if abs(direction.x) > abs(direction.y):
		direction.x *= -1  # 좌우 튕김
	else:
		direction.y *= -1  # 위아래 튕김

	rotation = direction.angle()

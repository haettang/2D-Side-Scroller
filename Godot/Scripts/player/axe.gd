extends Area2D

@export var speed := 500
@export var throw_angle := -60  # ← 테스트하면서 포물선 각도 조절
@export var rotation_speed := 480  # 도끼 회전 속도 (도/초)

var direction := 1  # 1 = 오른쪽, -1 = 왼쪽
var velocity := Vector2.ZERO
var has_hit := false

@onready var notifier = $VisibleOnScreenNotifier2D

func _ready():
	# 방향과 각도 기반 초기 속도 계산
	var angle_rad = deg_to_rad(throw_angle)
	velocity = Vector2(cos(angle_rad) * direction, sin(angle_rad)) * speed

	connect("body_entered", Callable(self, "_on_body_entered"))
	notifier.connect("screen_exited", Callable(self, "queue_free"))
		

func _physics_process(delta):
	if has_hit:
		return

	position += velocity * delta

	# 중력 적용 (간접적 포물선 구현)
	velocity.y += 800 * delta  # 중력 값은 필요시 조정

	# 회전
	rotation += deg_to_rad(rotation_speed * delta) * direction

func _on_body_entered(body):
	if has_hit:
		return

	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(5)
		if body.has_method("apply_knockback"):
			body.apply_knockback(direction)
		queue_free()

	# 타일맵이나 벽 등 모든 StaticBody2D에 반응
	elif body is TileMap:
		has_hit = true
		await get_tree().create_timer(1.0).timeout
		queue_free()

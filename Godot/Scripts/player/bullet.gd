# Arrow.gd
extends Area2D

@onready var audioplayer = $AudioStreamPlayer2D
@export var speed := 800
var direction := 1  # 1 = 오른쪽, -1 = 왼쪽

func _ready():
	# 1) body_entered 신호 연결
	connect("body_entered", Callable(self, "_on_body_entered"))
	# 2) 화면 벗어났을 때 자동 제거
	$VisibleOnScreenNotifier2D.connect("screen_exited", Callable(self, "queue_free"))

func _process(delta):
	# 화살 이동
	position.x += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(3)
		if body.has_method("apply_knockback"):
			body.apply_knockback(direction)
		queue_free()

	# 타일맵이나 벽 등 모든 StaticBody2D에 반응
	elif body is TileMap:
		queue_free()

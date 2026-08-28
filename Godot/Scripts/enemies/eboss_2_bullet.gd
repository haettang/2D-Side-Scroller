extends Area2D

@onready var audioplayer = $AudioStreamPlayer2D
@onready var anim_sprite = $AnimatedSprite2D
@export var speed := 400
var direction := Vector2.ZERO

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	$VisibleOnScreenNotifier2D.connect("screen_exited", Callable(self, "queue_free"))
	audioplayer.stream = preload("res://sounds/WAV_Fireball_Launch_1/WAV_Fireball_Launch_1.wav")
	audioplayer.play()
	
func _physics_process(delta):
	position += direction * speed * delta
	anim_sprite.play("default")

func initialize(target_position: Vector2):
	# 방향 설정: 단위 벡터로 정규화
	direction = (target_position - global_position).normalized()

	# 총알이 회전해서 날아가도록 하려면 방향을 각도로 바꿔서 적용
	rotation = direction.angle()

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(global_position)  # 또는 필요한 인자
		queue_free()
	elif body is TileMap or body is StaticBody2D:
		queue_free()

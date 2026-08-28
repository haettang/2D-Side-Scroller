extends Area2D

@onready var audioplayer = $AudioStreamPlayer2D
@onready var anim_sprite = $AnimatedSprite2D
@export var speed := 800
@export var wait_time := 2.0  # 대기 시간

var direction := Vector2.ZERO
var player: Node2D = null
var boss: Node2D = null
var launched := false
var offset_from_boss := Vector2(0, -64)  # 보스 머리 위 위치

func _ready():
	anim_sprite.play("default")
	$VisibleOnScreenNotifier2D.connect("screen_exited", Callable(self, "queue_free"))
	connect("body_entered", Callable(self, "_on_body_entered"))

	audioplayer.stream = preload("res://sounds/WAV_Small_Spark_2/WAV_Small_Spark_2.wav")
	audioplayer.play()

	# 2초 후 발사
	await get_tree().create_timer(wait_time).timeout

	if player != null:
		launch_towards(player.global_position)
	else:
		queue_free()

func _physics_process(delta):
	if launched:
		position += direction * speed * delta
	else:
		if boss != null:
			global_position = boss.global_position + offset_from_boss
		if player != null:
			look_at(player.global_position)

func initialize(player_ref: Node2D, boss_ref: Node2D):
	player = player_ref
	boss = boss_ref

func launch_towards(target_position: Vector2):
	direction = (target_position - global_position).normalized()
	rotation = direction.angle()
	launched = true

func _on_body_entered(body):
	if launched and body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(global_position)
		queue_free()
	elif launched and (body is TileMap or body is StaticBody2D):
		queue_free()

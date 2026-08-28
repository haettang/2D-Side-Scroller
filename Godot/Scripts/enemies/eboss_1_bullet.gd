extends Area2D

@onready var audioplayer = $AudioStreamPlayer2D
@onready var anim_sprite = $AnimatedSprite2D
@export var speed := 400
var direction := Vector2.ZERO
var has_bounced := false  # 1회만 튕기도록 추적

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	$VisibleOnScreenNotifier2D.connect("screen_exited", Callable(self, "queue_free"))
	audioplayer.stream = preload("res://sounds/WAV_Water_Circle_Swoosh_1/WAV_Water_Circle_Swoosh_1.wav")
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
			queue_free()

extends CharacterBody2D

@export var base_speed := 200
@onready var sprite = $AnimatedSprite2D
@onready var audioplayer = $AudioStreamPlayer2D

var direction := 1
var life_timer := 0.0


func set_direction(dir: int):
	direction = dir
	sprite.scale.x = -direction
	var texture = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)

func _ready():
		audioplayer.stream = preload("res://sounds/WAV_Water_Tornado_1/WAV_Water_Tornado_1.wav")

func _physics_process(delta):
	sprite.play("default")
	life_timer += delta
	position.x += direction * base_speed * delta

	if self.global_position.x <= -696 or self.global_position.x >= 960:
			queue_free()

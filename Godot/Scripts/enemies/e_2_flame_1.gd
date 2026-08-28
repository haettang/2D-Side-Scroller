extends Area2D

@onready var sprite = $AnimatedSprite2D  # 또는 $Sprite2D
@onready var timer = $Timer
@onready var audioplayer = $AudioStreamPlayer2D

var damage := 1  # 줄 데미지 값

func _ready():
	# 불기둥이 활성화되면 타이머 시작
	audioplayer.stream = preload("res://sounds/WAV_Campfire_2/WAV_Campfire_2.wav")
	audioplayer.play()
	timer.wait_time = 1.0
	timer.one_shot = true
	timer.start()
	connect("body_entered", Callable(self, "_on_body_entered"))
	sprite.play("default")

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(global_position)  # 또는 필요한 인자
			
func _on_Timer_timeout():
	queue_free()

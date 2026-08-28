extends Area2D

@onready var sprite = $Sprite2D
@onready var explosion_timer = $Timer

var velocity := Vector2(0, 400)  # 낙하 속도
var has_exploded := false
var fire_pillar_scene := preload("res://e2_flame1.tscn")
var tilemap_y := 250  # 고정 y좌표

func _ready():
	explosion_timer.wait_time = 1.0
	explosion_timer.one_shot = true
	explosion_timer.timeout.connect(_on_explosion_timeout)

func _physics_process(delta):
	if has_exploded:
		return
	
	position += velocity * delta
	
	# 타일맵 Y 좌표 이하로 내려가면 폭발
	if position.y >= tilemap_y:
		explode()

func explode():
	if has_exploded:
		return
	has_exploded = true
	
	sprite.visible = false
	velocity = Vector2.ZERO
	
	spawn_fire()
	explosion_timer.start()

func spawn_fire():
	for x in range(-960, 961, 64):  # x=-960~960까지 128 간격
		var pillar = fire_pillar_scene.instantiate()
		get_parent().add_child(pillar)
		pillar.global_position = Vector2(x, tilemap_y)

func _on_explosion_timeout():
	queue_free()

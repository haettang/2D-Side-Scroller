extends Area2D

@export var grow_duration := 0.3
@export var swing_angle_deg := 30
@export var swing_duration := 1.2
@export var beam_length := 400
@export var beam_thickness := 32

@onready var beam_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D
@onready var tip_marker = $Marker2D
@onready var audioplayer = $AudioStreamPlayer2D

var grow_timer := 0.0
var is_grown := false
var swing_timer := 0.0
var start_angle := 0.0
var target_angle := 0.0

var boss_node: CharacterBody2D = null
var clockwise: bool = true  # 회전 방향

func _ready():
	beam_sprite.scale.x = 0.0
	beam_sprite.centered = false
	beam_sprite.position = Vector2.ZERO
	tip_marker.position = Vector2(beam_length, 0)
	
	audioplayer.stream = preload("res://sounds/WAV_Water_Swoosh_2/WAV_Water_Swoosh_2.wav")
	audioplayer.play()

	var rect_shape := RectangleShape2D.new()
	rect_shape.size = Vector2(beam_length, beam_thickness)
	collision_shape.shape = rect_shape
	collision_shape.position = Vector2(beam_length / 2, 0)
	collision_shape.scale.x = 0.0

func initialize(from_pos: Vector2, target_pos: Vector2, boss: Node2D, rotate_clockwise := true):
	global_position = from_pos
	boss_node = boss
	clockwise = rotate_clockwise

	var dir = target_pos - from_pos
	rotation = dir.angle()
	tip_marker.position = Vector2(beam_length, 0)

func _process(delta):
	beam_sprite.play("default")

	# 빔 위치를 보스 위치에 고정
	if boss_node:
		global_position = boss_node.global_position

	if not is_grown:
		grow_timer += delta
		var grow_t = min(grow_timer / grow_duration, 1.0)
		beam_sprite.scale.x = grow_t
		collision_shape.scale.x = grow_t

		if grow_t >= 1.0:
			is_grown = true
			start_angle = rotation
			target_angle = start_angle + deg_to_rad(swing_angle_deg if clockwise else -swing_angle_deg)
	else:
		swing_timer += delta
		var swing_t = min(swing_timer / swing_duration, 1.0)
		rotation = lerp_angle(start_angle, target_angle, swing_t)

		if swing_t >= 1.0:
			queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(global_position)

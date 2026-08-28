extends CharacterBody2D

signal attack_signal(pattern_id)

@onready var sprite = $AnimatedSprite2D
@onready var attack_timer = $AttackTimer
@onready var wave_spawn_point = $Marker2D

var bullet = preload("res://eboss1_bullet.tscn")
var beam = preload("res://eboss1_beam.tscn")
var icebullet = preload("res://eboss1_bulletice.tscn")
var wave_scene = preload("res://e1_wave.tscn")
var ice_spear_scene = preload("res://e1_spear.tscn")

var player = null
var is_attacking = false
var attack_patterns = [0, 1, 2, 3, 4, 5]
var move_direction := Vector2.ZERO
var direction_change_timer := 0.0
const DIRECTION_CHANGE_INTERVAL := 3.0

var hp_e := 100
var max_hp := 100

var is_transformed := false
var has_played_trans := false

func _ready():
	z_index = 1000
	player = get_tree().get_current_scene().get_node_or_null("player")

	if player == null:
		push_warning("Player 노드를 찾을 수 없습니다.")
	else:
		sprite.play("idle")

	attack_timer.wait_time = 3.0
	attack_timer.one_shot = true
	attack_timer.start()

	attack_timer.timeout.connect(_on_AttackTimer_timeout)
	connect("attack_signal", Callable(self, "_on_attack_signal"))

	add_to_group("enemies")

func _process(delta):
	if player == null:
		return

	if not is_attacking:
		if is_transformed:
			if sprite.animation != "power":
				sprite.play("power")
		else:
			if sprite.animation != "idle":
				sprite.play("idle")

	if is_transformed and sprite.animation == "trans" and not sprite.is_playing():
		if not has_played_trans:
			sprite.play("power")
			has_played_trans = true

	var distance = abs(global_position.x - player.global_position.x)
	var to_player_dir = sign(player.global_position.x - global_position.x)
	var target_direction = 0

	if distance < 100:
		target_direction = -to_player_dir
	elif distance > 500:
		target_direction = to_player_dir
	else:
		direction_change_timer -= delta
		if direction_change_timer <= 0:
			direction_change_timer = DIRECTION_CHANGE_INTERVAL
			target_direction = (randi() % 2) * 2 - 1
		else:
			target_direction = move_direction.x

	move_direction.x = target_direction
	move_direction.y = 0

	var speed = 100
	position.x += move_direction.x * speed * delta

	if move_direction.x != 0:
		sprite.scale.x = move_direction.x

	for circle in [$Node/circle1, $Node/circle2, $Node/circle3, $Node/circle4]:
		if circle.visible:
			circle.global_position = global_position + Vector2(0, -128)

func take_damage(amount := 1):
	hp_e -= amount + (randi_range(-1, 1))
	if hp_e <= 0:
		queue_free()
	elif not is_transformed and hp_e <= 50:
		is_transformed = true
		sprite.play("trans")

func get_hp() -> int:
	return hp_e

func get_max_hp() -> int:
	return max_hp

func _on_AttackTimer_timeout():
	if is_attacking:
		return
	is_attacking = true
	var pattern: int
	
	
	# Phase two uses the more demanding half of the attack set.
	if hp_e > max_hp / 2:
		pattern = randi_range(0, 2)
	else:
		pattern = randi_range(2, 5)
	emit_signal("attack_signal", pattern)

func _on_attack_signal(pattern_id):
	match pattern_id:
		0:
			attack_pattern_0()
		1:
			attack_pattern_1()
		2:
			attack_pattern_2()
		3:
			attack_pattern_3()
		4:
			attack_pattern_4()
		5:
			attack_pattern_5()

func attack_pattern_0():
	show_magic_circle($Node/circle1)
	for i in range(7):
		var b = bullet.instantiate()
		get_parent().add_child(b)
		b.global_position = global_position
		b.initialize(player.global_position)
		await get_tree().create_timer(0.2).timeout
	end_attack()

func attack_pattern_1():
	show_magic_circle($Node/circle2)
	var beam_instance = beam.instantiate()
	get_parent().add_child(beam_instance)
	beam_instance.initialize(global_position, player.global_position, self)
	end_attack()

func attack_pattern_2():
	show_magic_circle($Node/circle3)
	if player == null:
		return

	var wave = wave_scene.instantiate()
	get_parent().add_child(wave)

	wave.global_position = wave_spawn_point.global_position
	var direction = sign(player.global_position.x - global_position.x)
	wave.global_position.x += direction * 128
	wave.global_position.y -= 64

	wave.set_direction(direction)
	end_attack()

func attack_pattern_3():
	show_magic_circle($Node/circle1)
	for i in range(7):
		var ib = icebullet.instantiate()
		get_parent().add_child(ib)
		ib.global_position = global_position
		ib.initialize(player.global_position)
		await get_tree().create_timer(0.2).timeout
	end_attack()

func attack_pattern_4():
	show_magic_circle($Node/circle4)
	var ice_spear = ice_spear_scene.instantiate()
	get_parent().add_child(ice_spear)
	ice_spear.initialize(player, self)
	end_attack()

func attack_pattern_5():
	show_magic_circle($Node/circle2)
	if player == null:
		return

	var from_pos = global_position
	var to_pos = player.global_position

	var beam_clockwise = beam.instantiate()
	var beam_counter = beam.instantiate()

	get_parent().add_child(beam_clockwise)
	get_parent().add_child(beam_counter)

	beam_clockwise.initialize(from_pos, to_pos, self, true)
	beam_counter.initialize(from_pos, to_pos, self, false)

	end_attack()

func end_attack():
	is_attacking = false
	attack_timer.start()

func show_magic_circle(circle: Sprite2D) -> void:
	circle.visible = true
	circle.modulate.a = 0.0

	var tween := get_tree().create_tween()
	tween.tween_property(circle, "global_position", global_position + Vector2(0, -128), 0.01)
	tween.tween_property(circle, "modulate:a", 1.0, 0.5)
	tween.tween_interval(1.0)
	tween.tween_property(circle, "modulate:a", 0.0, 0.5)
	tween.tween_callback(Callable(circle, "hide"))

	circle.process_mode = Node.PROCESS_MODE_ALWAYS

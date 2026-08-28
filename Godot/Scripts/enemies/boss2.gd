extends CharacterBody2D

signal attack_signal(pattern_id)

@onready var sprite = $AnimatedSprite2D
@onready var attack_timer = $AttackTimer  # Timer 노드가 보스에 있어야 함

var bullet = preload("res://eboss2_bullet.tscn")

var player = null
var is_attacking = false
var attack_patterns = [0, 1, 2, 3]  # 공격 패턴 ID
var move_direction := Vector2.ZERO
var direction_change_timer := 0.0
const DIRECTION_CHANGE_INTERVAL := 1.5  # 1.5초마다 랜덤 방향 변경

var hp_e := 100
var max_hp := 100  # 최대 체력 설정

func _ready():
	player = get_tree().get_current_scene().get_node_or_null("player")

	if player == null:
		push_warning("Player 노드를 찾을 수 없습니다.")
	else:
		sprite.play("idle")

	# 타이머 설정
	attack_timer.wait_time = 3.0
	attack_timer.one_shot = true
	attack_timer.start()

	# 시그널 연결 (중요!)
	attack_timer.timeout.connect(_on_AttackTimer_timeout)

	# 공격 시그널 연결
	connect("attack_signal", Callable(self, "_on_attack_signal"))

	add_to_group("enemies")

func _process(delta):
	if player == null:
		return

	# 공격 중이 아니면 idle 유지
	if not is_attacking and sprite.animation != "idle":
		sprite.play("idle")

	# 플레이어와의 x축 거리 및 방향 계산
	var distance = abs(global_position.x - player.global_position.x)
	var to_player_dir = sign(player.global_position.x - global_position.x)
	var target_direction = 0  # 최종 이동 방향: -1, 0, +1

	if distance < 100:
		target_direction = -to_player_dir
	elif distance > 500:
		target_direction = to_player_dir
	else:
		# 100~500 사이일 때
		direction_change_timer -= delta
		if direction_change_timer <= 0:
			direction_change_timer = DIRECTION_CHANGE_INTERVAL
			# -1 또는 +1 중 하나로 방향 선택 (0은 멈춤 방지)
			target_direction = (randi() % 2) * 2 - 1  
		else:
			# 타이머 갱신 전까지는 기존 이동 방향 유지
			target_direction = move_direction.x

	# 최종 방향을 move_direction에 반영
	move_direction.x = target_direction
	move_direction.y = 0  # y축 이동 없음

	# 실제 이동 (속도 80, 필요시 조절)
	var speed = 100
	position.x += move_direction.x * speed * delta

	# 이동 방향에 따라 스프라이트 좌우 뒤집기
	if move_direction.x != 0:
		sprite.scale.x = move_direction.x


	# 공격 중이 아니면 idle 유지
	if not is_attacking and sprite.animation != "idle":
		sprite.play("idle")

func take_damage(amount := 1):  # amount에 기본값 1 설정
	hp_e -= amount + (randi_range(-1, 1))
	if hp_e <= 0:
		queue_free()

func get_hp() -> int:
	return hp_e

func get_max_hp() -> int:
	return max_hp
		
func _on_AttackTimer_timeout():
	if is_attacking:
		return
	is_attacking = true
	var pattern: int
	
	pattern = attack_patterns.pick_random()
	
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

func show_magic_circle(circle: Sprite2D) -> void:
	circle.visible = true
	circle.global_position = global_position + Vector2(0, -128)
	circle.modulate.a = 0.0

	var tween := get_tree().create_tween()
	tween.tween_property(circle, "modulate:a", 1.0, 0.5)  # fade-in
	tween.tween_interval(1.0)                            # 유지
	tween.tween_property(circle, "modulate:a", 0.0, 0.5)  # fade-out
	tween.tween_callback(Callable(circle, "hide"))

func attack_pattern_0():
	show_magic_circle($Node/circle1)
	for i in range(3):
		var b = bullet.instantiate()
		get_parent().add_child(b)
		b.global_position = global_position
		b.initialize(player.global_position)
		await get_tree().create_timer(0.2).timeout
	sprite.play("attack")
	await sprite.animation_finished
	end_attack()

func attack_pattern_1():
	show_magic_circle($Node/circle2)
	sprite.play("attack")
	if player == null:
		end_attack()
		return
	var fire_pillar_scene = preload("res://e2_flame1.tscn")
	var origin = player.global_position
	origin.y = 250  # Y 좌표 고정
	var pillar_count := 5         # 양 방향으로 생성할 개수
	var spacing := 64             # 간격 (픽셀)
	var delay := 0.2           # 생성 지연 (퍼져나가는 느낌)
	# 플레이어 기준 중심 기둥
	var center = fire_pillar_scene.instantiate()
	get_parent().add_child(center)
	center.global_position = origin
	# 좌우로 확산
	for i in range(1, pillar_count + 1):
		await get_tree().create_timer(delay).timeout
		for direction in [-1, 1]:  # -1: 왼쪽, 1: 오른쪽
			var offset = Vector2(spacing * i * direction, 0)
			var pillar = fire_pillar_scene.instantiate()
			get_parent().add_child(pillar)
			pillar.global_position = origin + offset
	await sprite.animation_finished
	end_attack()

func attack_pattern_2():
	show_magic_circle($Node/circle3)
	sprite.play("attack")
	var angle_list = [15, 45, 75, 105, 135, 165]
	# 각 방향마다 5발씩 동시에 발사
	for i in range(5):
		for angle_deg in angle_list:
			var angle_rad = deg_to_rad(angle_deg)
			var direction = Vector2(cos(angle_rad), -sin(angle_rad)).normalized()

			var b = bullet.instantiate()
			get_parent().add_child(b)
			b.global_position = global_position
			b.initialize(global_position + direction * 100)
		await get_tree().create_timer(0.2).timeout  # 연사 간격
	await sprite.animation_finished
	end_attack()

func attack_pattern_3():
	show_magic_circle($Node/circle4)
	sprite.play("attack")

	var drop_delay := 1.0
	var meteor_scene = preload("res://e2_methor.tscn")
	var drop_area_x := 800
	var drop_height := -300

	var meteor = meteor_scene.instantiate()
	get_parent().add_child(meteor)

	var x_pos = global_position.x + randf_range(-drop_area_x, drop_area_x)
	meteor.global_position = Vector2(x_pos, drop_height)

	await get_tree().create_timer(drop_delay).timeout

	# 애니메이션 종료까지 대기
	await sprite.animation_finished

	end_attack()


func end_attack():
	is_attacking = false
	attack_timer.start()

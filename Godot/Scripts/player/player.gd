extends CharacterBody2D

const GRAVITY = 980
const JUMP_FORCE = -500
const MOVE_SPEED = 500
const MAX_JUMPS = 2
const FALL_LIMIT_Y = 500

var jump_count = 0
var attack = 0
var startposition = Vector2.ZERO
var stage_min_x: float = -100000
var stage_max_x: float = 100000

var is_invincible := false
var invincible_time := 1.0
var invincible_timer := 0.0

# 공격 쿨타임 설정
var melee_cooldown := 0.5
var ranged_cooldown := 0.3

# 타이머
var melee_timer := 0.0
var ranged_timer := 0.0

@onready var anim_sprite = $AnimatedSprite2D
@onready var ground_check = $GroundRayCast2D
@onready var cam = $Camera2D
@onready var arrow_scene = preload("res://Bullet.tscn")
@onready var axe_scene = preload("res://axe.tscn")
@onready var sword_scene = preload("res://sword.tscn")
@onready var audioplayer = $AudioStreamPlayer2D

func _ready():
	add_to_group("player")
	setup_stage_bounds()
	var parent = get_parent()
	if parent.has_node("spawnpoint"):
		startposition = parent.get_node("spawnpoint").global_position
	else:
		startposition = global_position

func _physics_process(delta):
	if !is_inside_tree():
		return
	melee_timer = max(melee_timer - delta, 0)
	ranged_timer = max(ranged_timer - delta, 0)

	handle_input()
	apply_gravity(delta)
	update_animation()
	update_invincibility(delta)
	check_restart()
	move_and_slide()

func handle_input():
	var input_vector = Vector2.ZERO

	# 근접 공격
	if Input.is_action_just_pressed("attack") and melee_timer <= 0:
		attack = 1
		melee_timer = melee_cooldown
		audioplayer.stream = preload("res://sounds/snd_knife/snd_knife.wav")
		audioplayer.play()

		var sword = sword_scene.instantiate()
		get_parent().add_child(sword)

		var offset = Vector2(48, 0)
		if anim_sprite.scale.x < 0:
			offset.x *= -1
		sword.global_position = global_position + offset
		sword.scale.x = anim_sprite.scale.x

	# 원거리 공격
	if Input.is_action_just_pressed("rangedattack") and ranged_timer <= 0:
		ranged_timer = ranged_cooldown

		if Global.weaponselect == 0:
			var arrow = arrow_scene.instantiate()
			arrow.global_position = global_position
			arrow.direction = sign(anim_sprite.scale.x)
			arrow.scale.x = arrow.direction
			get_parent().add_child(arrow)
			audioplayer.stream = preload("res://sounds/snd_arrow/snd_arrow.wav")
			audioplayer.play()

		elif Global.weaponselect == 1:
			var axe = axe_scene.instantiate()
			axe.global_position = global_position
			axe.direction = sign(anim_sprite.scale.x)
			axe.scale.x = axe.direction
			get_parent().add_child(axe)
			audioplayer.stream = preload("res://sounds/snd_axe/snd_axe.wav")
			audioplayer.play()

	# 점프
	if Input.is_action_just_pressed("jump") and jump_count < MAX_JUMPS:
		velocity.y = JUMP_FORCE
		jump_count += 1

	# 이동
	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1
		anim_sprite.scale.x = 1
	elif Input.is_action_pressed("ui_left"):
		input_vector.x -= 1
		anim_sprite.scale.x = -1

	velocity.x = input_vector.x * MOVE_SPEED

	if is_on_floor():
		jump_count = 0

	global_position.x = clamp(global_position.x, stage_min_x, stage_max_x)

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += GRAVITY * delta

func update_animation():
	if attack != 0:
		if anim_sprite.animation != "attack":
			anim_sprite.play("attack")
		if anim_sprite.frame == 2:
			attack = 0
	elif velocity.y != 0:
		if anim_sprite.animation != "jump":
			anim_sprite.play("jump")
	elif velocity.x != 0:
		if anim_sprite.animation != "move":
			anim_sprite.play("move")
	elif is_on_floor():
		if anim_sprite.animation != "idle":
			anim_sprite.play("idle")

func update_invincibility(delta):
	if is_invincible:
		invincible_timer -= delta
		if invincible_timer <= 0:
			is_invincible = false
			modulate.a = 1.0

func take_damage(source_position: Vector2):
	if is_invincible:
		return

	Global.hp_p -= 1
	print("hp - 1")
	is_invincible = true
	invincible_timer = invincible_time
	modulate.a = 0.6

	var direction = sign(global_position.x - source_position.x)
	velocity.x = direction * 300
	velocity.y = -200

func check_restart():
	if global_position.y > FALL_LIMIT_Y:
		respawn()
	elif Global.hp_p <= 0:
		get_tree().reload_current_scene()
		Global.hp_p = 5

func respawn():
	global_position = Vector2(startposition.x, startposition.y)
	velocity = Vector2.ZERO
	jump_count = 0
	Global.hp_p -= 1

func setup_stage_bounds():
	var parent = get_parent()
	if parent.has_node("backgroundimage"):
		var bg = parent.get_node("backgroundimage")
		if bg is Sprite2D and bg.texture:
			var bg_size = bg.texture.get_size() * bg.scale
			var bg_global_pos = bg.global_position
			stage_min_x = (bg_global_pos.x - bg_size.x / 2) + 32
			stage_max_x = (bg_global_pos.x + bg_size.x / 2) - 32

extends Node2D

const VIEWPORT_SIZE: Vector2 = Vector2(1152, 648)
@export var margin: Vector2 = Vector2(20, 20)

@onready var bow_icon = $bow
@onready var axe_icon = $axe

@onready var hp_bar = $ProgressBar

func _ready():
	hp_bar.max_value = Global.max_hp_p
	hp_bar.value = Global.hp_p

func _process(_delta):
	_update_position()
	hp_bar.value = Global.hp_p
	
	# 상태에 따라 아이콘 표시 조정
	if Global.weaponselect == 0:
		bow_icon.visible = true
		axe_icon.visible = false
	else:
		bow_icon.visible = false
		axe_icon.visible = true

func _update_position():
	var vp_size: Vector2 = VIEWPORT_SIZE
	var offset = Vector2(
		-vp_size.x * 0.3 + margin.x,
		 vp_size.y * 0.3 - margin.y
	)

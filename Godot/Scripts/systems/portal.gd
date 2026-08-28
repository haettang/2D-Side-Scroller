extends Area2D

@onready var sprite = $Sprite
@onready var collision = $CollisionShape2D
@onready var monsters_node = get_tree().current_scene.get_node_or_null("Monsters")

var activated := false

var stage_order := [
	"stage1",
	"bossstage1",
	"stage2",
	"bossstage2",
	"stage3",
	"bossstage3"
]

func _ready():
	visible = false
	collision.disabled = true
	connect("body_entered", _on_body_entered)

func _process(delta):
	if activated or monsters_node == null:
		return

	if monsters_node.get_child_count() == 0:
		activate_portal()

func activate_portal():
	activated = true
	visible = true
	collision.disabled = false

func _on_body_entered(body):
	if activated and body.name == "player":
		go_to_next_stage()

func go_to_next_stage():
	var current_scene_path = get_tree().current_scene.scene_file_path
	var current_name = current_scene_path.get_file().get_basename()

	var index = stage_order.find(current_name)
	if index == -1 or index + 1 >= stage_order.size():
		return

	var next_stage_path = "res://scenes/%s.tscn" % stage_order[index + 1]

	if ResourceLoader.exists(next_stage_path):
		get_tree().change_scene_to_file(next_stage_path)

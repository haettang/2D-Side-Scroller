extends Node

var music_player: AudioStreamPlayer
var max_hp_p = 5
var hp_p = 5
var weaponselect = 0  # 0 = 활, 1 = 도끼

# 스테이지 순서 정의
var stage_order := [
	"stage1",
	"bossstage1",
	"stage2",
	"bossstage2",
	"stage3",
	"bossstage3",
	"ending"
]

func _ready():
	# 게임 시작 시 AudioStreamPlayer 노드 생성 및 설정
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"  # 오디오 버스 이름 확인
	music_player.volume_db = -8
	add_child(music_player)

func _process(delta):
	handle_input()

func handle_input():
	if Input.is_action_just_pressed("swap"):
		weaponselect = (weaponselect + 1) % 2
	
	if Input.is_action_just_pressed("skip"):
		skip_to_next_stage()

func skip_to_next_stage():
	var current_path = get_tree().current_scene.scene_file_path
	var current_name = current_path.get_file().get_basename()

	var index = stage_order.find(current_name)
	if index == -1 or index + 1 >= stage_order.size():
		print("다음 스테이지 없음.")
		return

	var next_name = stage_order[index + 1]
	var next_path = "res://scenes/%s.tscn" % next_name

	if FileAccess.file_exists(next_path):
		print("스테이지 스킵: %s → %s" % [current_name, next_name])
		get_tree().change_scene_to_file(next_path)
	else:
		push_error("스테이지 파일 없음: %s" % next_path)

# 스테이지가 호출할 함수
func play_stage_music(music_stream: AudioStream):
	if music_player.stream == music_stream:
		return  # 같은 음악이면 재생 유지
	music_player.stop()
	music_player.stream = music_stream
	music_player.play()

func stop_music():
	music_player.stop()

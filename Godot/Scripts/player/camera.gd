extends Camera2D

func _ready():
	# 1) 이 카메라를 활성화
	make_current()

	# 2) Stage 씬 루트에서 backgroundimage(Sprite2D) 가져오기
	var stage = get_tree().get_current_scene() as Node2D
	var bg = stage.get_node("backgroundimage") as Sprite2D
	if bg == null or bg.texture == null:
		push_error("Camera2D: backgroundimage(Sprite2D) 또는 texture를 찾을 수 없습니다.")
		return

	# 3) 배경 이미지 크기(픽셀)와 맵의 절대 경계 구하기
	var tex_size   = bg.texture.get_size() * bg.scale
	var center_pos = bg.global_position
	var min_x = center_pos.x - tex_size.x * 0.5
	var max_x = center_pos.x + tex_size.x * 0.5
	var min_y = center_pos.y - tex_size.y * 0.5
	var max_y = center_pos.y + tex_size.y * 0.5

	# 4) 화면(뷰포트) 크기와 절반값
	var viewport_size    = get_viewport().get_visible_rect().size
	var half_screen = viewport_size * 0.5

	# 5) 카메라 중심 제한 계산
	#    카메라의 global_position 이 이 범위를 벗어나지 않도록 설정
	limit_left   = int(min_x)
	limit_right  = int(max_x)
	limit_top    = int(min_y)
	limit_bottom = int(max_y)
	

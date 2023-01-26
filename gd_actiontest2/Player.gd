extends KinematicBody2D

const GHOST_EFFECT = preload("res://GhostEffect.tscn")

const MOVE_SPEED := 500.0
const MOVE_DECAY := 0.9
const JUMP_POWER := 1500.0
const GRAVITY := 5000.0
const JUMP_SCALE_TIME := 0.2
const JUMP_SCALE_VAL_JUMP := 0.3
const JUMP_SCALE_VAL_LANDING := 0.25

const JUMP_CNT_MAX = 2 # 2段ジャンプまで可能.

# 状態
enum eState {
	IDLE,
	RUN, # 走る
	JUMP # ジャンプ
}

# ジャンプによるスケール状態
enum eJumpScale {
	NONE,
	JUMPING, #ジャンプ開始
	LANDING, # 着地開始
}

onready var _spr_normal = $Sprite
onready var _spr_frontflip = $SpriteFrontFlip

onready var _spr = $Sprite

# 移動量
var velocity = Vector2()

var pressed_move_key = false
var anim_time = 0
var state = eState.IDLE
var jump_scale = eJumpScale.NONE
var jump_scale_timer = 0
var is_left = false # 左を向いているかどうか
var ghost_cnt = 0.0
var jump_cnt = 0

# ゴーストエフェクトを表示する CanvasLayer
onready var _ghost_effects = $"../GhostEffectLayer"

func is_idle() -> bool:
	return state == eState.IDLE

func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	
	# ジャンプ判定
	_update_jump()
	
	# 横移動
	_move_horizontal(delta)
				
	# 重力と着地を処理する
	_update_landing(delta)
	
	# 残像エフェクトの処理
	_proc_ghost_effect(delta)
	
	# アニメーションタイマー更新
	anim_time += delta
	# スプライトフレームを設定
	_spr.frame = _get_anim_frame()
	_spr.flip_h = is_left # 反転する
	
	# ジャンプ・着地演出
	_update_jump_scale_anim(delta)

# ジャンプ判定
func _update_jump() -> void:
	if jump_cnt >= JUMP_CNT_MAX:
		return # ジャンプ回数の限度を超えた.

	# Spaceキーでジャンプ開始
	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = -JUMP_POWER
		state = eState.JUMP
		jump_scale = eJumpScale.JUMPING
		jump_scale_timer = JUMP_SCALE_TIME
		
		# ジャンプパーティクル出現.
		_add_particle(jump_cnt > 0)
		
		jump_cnt += 1

# 左右移動判定
func _move_horizontal(delta:float) -> void:
	# 横移動の判定
	pressed_move_key = false
	if Input.is_action_pressed("ui_left"):
		velocity.x = -1.0 * MOVE_SPEED # 左に移動
		is_left = true
		pressed_move_key = true
	elif Input.is_action_pressed("ui_right"):
		velocity.x = 1.0 * MOVE_SPEED # 右に移動
		is_left = false
		pressed_move_key = true

	if state != eState.JUMP:
		# ジャンプ中でなければ走り判定
		if abs(velocity.x) < 3.0:
			state = eState.IDLE
		else:
			if state != eState.RUN:
				# 走り始め.
				_add_particle(true, true)
			state = eState.RUN
	
	# 速度減衰
	#velocity.x *= MOVE_DECAY
	velocity.x *= pow(0.002, delta) # FPS変わっても有効にするための特殊処理.

# 重力と着地を処理する
func _update_landing(delta:float) -> void:
	velocity.y += GRAVITY * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	#position += velocity
	if is_on_floor():
		# 床に着地
		velocity.y = 0
		if state == eState.JUMP:
			# 着地した直後
			state = eState.RUN
			jump_scale = eJumpScale.LANDING
			jump_scale_timer = JUMP_SCALE_TIME
			_add_particle(true)
			jump_cnt = 0
	else:
		state = eState.JUMP

# 残像エフェクトの処理	
func _proc_ghost_effect(delta:float) -> void:
	if state == eState.IDLE:
		ghost_cnt = 0
		return # 停止中は何もしない
		
	# 残像エフェクトを生成判定
	ghost_cnt += delta / 0.016
	if ghost_cnt > 4 and Common.is_ghost:
		ghost_cnt = 0
		# 残像エフェクト生成
		var eft = GHOST_EFFECT.instance()
		var pos = position
		if jump_cnt >= JUMP_CNT_MAX:
			pos += Vector2(0, -28)
		eft.start(pos, _spr.scale, _spr.frame, _spr.flip_h, _spr.rotation, _spr.offset)
		_ghost_effects.add_child(eft)
	

# 現在の状態に対するアニメーションフレーム番号を取得する	
func _get_anim_frame() -> int:
	match state:
		eState.IDLE:
			var t = int(anim_time * 8) % 10
			if t == 0:
				t = 1
			else:
				t = 0
			return 0 + t
		eState.RUN:
			if pressed_move_key == false:
				return 4 # ブレーキ.
			
			var t = int(anim_time * 8) % 2
			return 2 + t
		_:
			return 2

# ジャンプ・着地によるスケールアニメーションの更新
func _update_jump_scale_anim(delta:float) -> void:
	_spr.visible = false
	if jump_cnt >= JUMP_CNT_MAX:
		# 2段ジャンプ時はスケールしない.
		jump_scale_timer = 0
		jump_scale = eJumpScale.NONE
		# 前転用スプライトに差し替え.
		_spr = _spr_frontflip
		_spr.visible = true
		if is_left:
			delta *= -1
		_spr.rotation_degrees += 2000 * delta
		return
	
	# もとに戻す.
	_spr = _spr_normal	
	_spr.visible = true
	jump_scale_timer -= delta
	if jump_scale_timer <= 0:
		# 演出終了
		jump_scale = eJumpScale.NONE
	match jump_scale:
		eJumpScale.JUMPING:
			# 縦に伸ばす
			var d = JUMP_SCALE_VAL_JUMP * cube_in_out(jump_scale_timer / JUMP_SCALE_TIME)
			_spr.scale.x = 1 - d
			_spr.scale.y = 1 + d * 3
		eJumpScale.LANDING:
			# 縦に潰す
			var d = JUMP_SCALE_VAL_LANDING * back_in_out(jump_scale_timer / JUMP_SCALE_TIME)
			_spr.scale.x = 1 + d
			_spr.scale.y = 1 - d * 1.5
		_:
			# もとに戻す
			_spr.scale.x = 1
			_spr.scale.y = 1

func _add_particle(is_gravity:bool, is_move:bool=false) -> void:
	for i in range(32):
		var ofs = Vector2(rand_range(-24, 24), rand_range(-12, 0))
		var speed = rand_range(10, 50)
		var deg = rand_range(45, 135)
		var rad = deg2rad(deg)
		var v = Vector2(
			cos(rad) * speed, -sin(rad) * speed
		)
		if is_move:
			v.x += sign(velocity.x) * -50 # 移動方向と逆.
		else:
			v.x += rand_range(0, 100) * sign(ofs.x)
		var sc = rand_range(0.5, 1.0)
		var t = rand_range(0.01, 0.5)
		Common.add_particle(position + ofs, v, sc, t, is_gravity)

func approach(a:float, b:float, step:float) -> float:
	var d = b - a
	step *= sign(d)
	var ret = a + step
	if sign(d) > 0:
		ret = min(ret, b)
	else:
		ret = max(ret, b)
	return ret

# 三次関数
func cube_in(t:float) -> float:
	return t * t * t
func cube_out(t:float) -> float:
	return 1 + (t - 1) * (t - 1) * (t - 1)
func cube_in_out(t:float) -> float:
	if t <= 0.5:
		return t * t * t * 4
	else :
		return 1 + (t - 1) * (t - 1) * (t - 1) * 4
# バウンス関数	
const B1 = 1 / 2.75
const B2 = 2 / 2.75
const B3 = 1.5 / 2.75
const B4 = 2.5 / 2.75
const B5 = 2.25 / 2.75
const B6 = 2.625 / 2.75
func bounce_in(t:float) -> float:
	t = 1 - t
	if (t < B1): return 1 - 7.5625 * t * t
	if (t < B2): return 1 - (7.5625 * (t - B3) * (t - B3) + .75)
	if (t < B4): return 1 - (7.5625 * (t - B5) * (t - B5) + .9375)
	
	return 1 - (7.5625 * (t - B6) * (t - B6) + .984375)

func bounce_out(t:float) -> float:
	if (t < B1): return 7.5625 * t * t
	if (t < B2): return 7.5625 * (t - B3) * (t - B3) + .75
	if (t < B4): return 7.5625 * (t - B5) * (t - B5) + .9375
	
	return 7.5625 * (t - B6) * (t - B6) + .984375
		
func expo_in(t:float) -> float:
	return pow(2, 10 * (t - 1))
func expo_out(t:float) -> float:
	return -pow(2, -10*t) + 1
func back_in(t:float) -> float:
	return t * t * (2.70158 * t - 1.70158)
func back_out(t:float) -> float:
	return 1 - (t - 1) * (t-1) * (-2.70158 * (t-1) - 1.70158)
func back_in_out(t:float) -> float:
	t *= 2
	if (t < 1):
		return t * t * (2.70158 * t - 1.70158) / 2
	else:
		t -= 1
		return (1 - (t - 1) * (t - 1) * (-2.70158 * (t - 1) - 1.70158)) / 2 + .5

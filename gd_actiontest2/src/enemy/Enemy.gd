extends CharacterBody2D

class_name Enemy

const MOVE_SPEED = 180
const GRAVITY = 20;
const JUMP_POWER = 500

enum eState {
	STAND_BY,
	WALK,
	JUMP,
	ESCAPE,
	VANISH,
}

enum eMode {
	WALK,
	JUMP,
	ESCAPE,
}

@export var mode = eMode.WALK


@onready var _spr = $Enemy
@onready var _collision = $CollisionShape2D

var _state = eState.STAND_BY
var _timer = 0.0
var _cnt = 0
var _velocity = Vector2.ZERO
var _move_speed = 0.0
var _is_left = true

func vanish() -> void:
	if _state == eState.VANISH:
		return
	_state = eState.VANISH
	_timer = 0.0
	_velocity.x += randf_range(-1, 1) * 300
	_velocity.y = randf_range(-1, -0.5) * 300
	_spr.offset = Vector2.ZERO

func _physics_process(delta: float) -> void:
	_cnt += 1
	_velocity.y += GRAVITY
	
	match _state:
		eState.STAND_BY:
			set_velocity(_velocity)
			move_and_slide()
			_velocity = velocity
			var target = Common.get_target_pos()
			var d = target - position
			if d.length() < 600:
				d = d.normalized()
				_velocity.x = d.x * MOVE_SPEED
				_move_speed = _velocity.x
				_is_left = true
				print(mode)
				match mode:
					eMode.WALK:
						_state = eState.WALK
					eMode.JUMP:
						_velocity.x = 0
						_state = eState.JUMP
					eMode.ESCAPE:
						_velocity.x = 0
						_state = eState.ESCAPE
		eState.WALK:
			set_velocity(_velocity)
			move_and_slide()
			_velocity = velocity
			if is_on_wall():
				# 壁にぶつかった.
				_is_left = _is_left == false
				_spr.flip_h = _is_left == false
				if _is_left:
					_velocity.x = _move_speed
				else:
					_velocity.x = -_move_speed
			
			_spr.offset.y = ((_cnt/8)%2) * 2
		eState.JUMP:
			_timer += delta
			set_velocity(_velocity)
			move_and_slide()
			_velocity = velocity
			if _timer > 3:
				_velocity.y = -JUMP_POWER
				_timer = 0
			if _timer < 2:
				_spr.offset.y = ((_cnt/8)%2) * 2
		eState.ESCAPE:
			var pos = Common.get_target_pos()
			var d = pos - position
			if d.length() < 128:
				# 近づいたら逃げる
				d = d.normalized()
				_velocity.x = d.x * -100
				if _velocity.x > 0:
					_is_left = false
				else:
					_is_left = true
			elif d.length() > 320:
				_velocity.x *= 0.9
			_spr.flip_h = _is_left == false
			
			set_velocity(_velocity)
			move_and_slide()
			_velocity = velocity
			_spr.offset.y = ((_cnt/8)%2) * 2
		eState.VANISH:
			_timer += delta
			_velocity *= 0.97
			position += _velocity * delta

			rotation = _timer * 8.0
			var t = int(_timer * 16)
			visible = t%2 == 0		
			if _timer > 1.0:
				queue_free()

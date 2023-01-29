extends KinematicBody2D

class_name Enemy

const GRAVITY = 30;

enum eState {
	STAND_BY,
	WALK,
	VANISH,
}

onready var _spr = $Enemy
onready var _collision = $CollisionShape2D

var _state = eState.STAND_BY
var _timer = 0.0
var _cnt = 0
var _velocity = Vector2.ZERO

func vanish() -> void:
	if _state == eState.VANISH:
		return
	_state = eState.VANISH
	_timer = 0.0
	_velocity.x += rand_range(-1, 1) * 300
	_velocity.y = rand_range(-1, -0.5) * 300
	_spr.offset = Vector2.ZERO

func _physics_process(delta: float) -> void:
	_cnt += 1
	_velocity.y += GRAVITY
	
	match _state:
		eState.STAND_BY:
			_velocity = move_and_slide(_velocity)
			var target = Common.get_target_pos()
			var d = target - position
			if d.length() < 600:
				d = d.normalized()
				_velocity.x = d.x * 100
				_state = eState.WALK
		eState.WALK:
			_velocity = move_and_slide(_velocity)
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

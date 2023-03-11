extends Node2D

class_name Tako

const MOVE_SPEED = 500
const INTERVAL = 5.0

enum eState {
	APPEAR,
	MAIN,
}

enum eMode {
	HORMING,
	INTERVAL,
}

var _timer = 0.0
var _state := eState.APPEAR
var _mode := eMode.HORMING
var _velocity = Vector2.ZERO

func setup(pos:Vector2, mode:eMode) -> void:
	_mode = mode
	position = pos
	scale = Vector2.ZERO

func _process(delta):
	_timer += delta
	match _state:
		eState.APPEAR:
			scale.x = _timer
			scale.y = _timer
			if _timer >= 1.0:
				scale = Vector2.ONE
				_state = eState.MAIN
				_timer = 0
		eState.MAIN:
			match _mode:
				eMode.HORMING:
					_update_horming(delta)
				eMode.INTERVAL:
					_update_interval(delta)
	if Common.is_in_screen(self) == false:
		queue_free()

func _update_horming(delta:float) -> void:
	var target = Common.get_target_pos()
	var d = target - position
	_velocity = d.normalized()
	_velocity *= 100
	position += _velocity * delta	

func _update_interval(delta:float) -> void:
	_velocity *= 0.97
	position += _velocity * delta
	if _timer > 1:
		rotation += _timer * 0.1
	if _timer > INTERVAL:
		var target = Common.get_target_pos()
		var d = target - position
		_velocity = d.normalized()
		_velocity *= MOVE_SPEED
		rotation = atan2(_velocity.y, _velocity.x)
		_timer = 0

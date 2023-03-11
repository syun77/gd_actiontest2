extends Node2D

const MOVE_SPEED = 200

enum eState {
	SIN_CURVE,
	WAIT,
	FALL,
}

@onready var _label = $Label
@onready var _spr = $Sprite2D

var _start = Vector2.ZERO
var _timer = 0.0
var _state := eState.SIN_CURVE
var _dy = 0.0


func setup(pos:Vector2) -> void:
	_start = pos
	position = _start

func _physics_process(delta):
	_timer += delta
	_label.visible = false	
	
	match _state:
		eState.SIN_CURVE:
			position.x -= MOVE_SPEED * delta
			position.y = _start.y + sin(_timer * 4) * 64
			
			var pos = Common.get_target_pos()
			var dx = abs(position.x - pos.x)
			var dy = _start.y - pos.y
			_label.text = "%d"%int(dx)
			if dx < 32 and dy < 64:
				_timer = 0
				_state = eState.WAIT
		eState.WAIT:
			_spr.rotation += (PI - _spr.rotation) * 0.1
			if _timer > 0.5:
				_state = eState.FALL
		eState.FALL:
			_dy += 1
			position.y += _dy
			
	
	if Common.is_in_screen(self) == false:
		queue_free()

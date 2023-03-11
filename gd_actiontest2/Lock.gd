extends StaticBody2D

class_name Lock

const GRAVITY = 10;

enum eState {
	STAND_BY,
	VANISH,
}

@onready var _collision = $CollisionShape2D

var _state = eState.STAND_BY
var _timer = 0.0
var _velocity = Vector2.ZERO

func vanish() -> void:
	_collision.disabled = true
	_state = eState.VANISH
	_velocity.x += randf_range(-1, 1) * 300
	_velocity.y += randf_range(-1, -0.5) * 300

func _process(delta: float) -> void:
	if _state == eState.VANISH:
		_velocity.y += GRAVITY
		_velocity *= 0.97
		position += _velocity * delta
		
		_timer += delta
		rotation = _timer * 8.0
		var t = int(_timer * 16)
		visible = t%2 == 0		
		if _timer > 1.0:
			queue_free()

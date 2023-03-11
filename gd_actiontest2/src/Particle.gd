extends Sprite2D

class_name Particle

const GRAVITY = 3

var _timer:float
var _max_timer:float
var _velocity:Vector2
var _max_scale:Vector2
var _is_gravity = true

# パーティクル開始.
func start(pos:Vector2, vec:Vector2, sc:float, t:float, is_gravity:bool):
	position = pos
	_velocity = vec
	scale = Vector2(sc, sc)
	_max_scale = scale
	_timer = t
	_max_timer = _timer
	_is_gravity = is_gravity

func _process(delta: float) -> void:
	_timer -= delta
	if _timer <= 0:
		# タイマー終了で消える
		queue_free()
		return
	
	if _is_gravity:
		_velocity.y += GRAVITY
	else:
		_velocity.y -= GRAVITY
	_velocity *= pow(0.05, delta)
	position += _velocity * delta
	
	var rate = _timer / _max_timer
	scale = _max_scale * rate
	modulate.a = rate


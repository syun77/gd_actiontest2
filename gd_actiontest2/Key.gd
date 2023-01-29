extends Area2D

class_name Key

enum eState {
	STAND_BY,
	UNLOCK,
	VANISH,
}

var _state = eState.STAND_BY
var _timer = 0.0

func _process(delta: float) -> void:
	match _state:
		eState.UNLOCK:
			var lock = _search_lock()
			if lock != null:
				var d = lock.position - position
				position += d * delta * 5
		eState.VANISH:
			_timer += delta
			var t = int(_timer * 24)
			visible = t%2 == 0
			visible = false
			if _timer > 0.5:
				queue_free()

func _search_lock() -> Lock:
	for obj in Common.get_layer("wall").get_children():
		if obj is Lock:
			return obj
	return null

func _on_Key_body_entered(body: Node) -> void:
	match _state:
		eState.STAND_BY:
			if body.name == "Player":
				_state = eState.UNLOCK
		eState.UNLOCK:
			if body is Lock:
				_state = eState.VANISH
				body.vanish()

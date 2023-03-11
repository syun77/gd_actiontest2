extends Node2D

@onready var _path = $Path2D/PathFollow2D

var _is_setpos = false
var _timer = 0.0

func _ready() -> void:
	visible = false

func _process(delta):
	visible = true
	_timer += delta * 0.2
	_path.progress_ratio = _timer
	
	if _is_setpos == false:
		var ofs = Common.get_camera_pos()
		position.x = ofs.x - (1024/2)
		position.y = ofs.y - (600/2)
		_is_setpos = true
	
	if _timer >= 1:
		queue_free()

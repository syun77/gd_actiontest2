extends Node2D

const WINDOW_OBJ = preload("res://Window.tscn")

enum eState {
	MAIN,
	POP_UP,
}

@onready var _player = $MainLayer/Player
@onready var _camera = $Camera2D

@onready var _main_layer = $MainLayer
@onready var _particle_layer = $ParticleLayer
@onready var _wall_layer = $WallLayer
@onready var _ui_layer = $UILayer

@onready var _hslider_fps = $UILayer/HSliderFPS
@onready var _label_fps = $UILayer/HSliderFPS/Label
@onready var _checkbox_window = $UILayer/CheckBoxWindow

var _board_list = []
var _ui_list = []
var _state = eState.MAIN
var _window = null

func _ready() -> void:
	_ui_list = [
		_hslider_fps,
		_checkbox_window,
	]
	
	for obj in _main_layer.get_children():
		if obj is Board:
			_board_list.append(obj)
	
	Common.layer_particle = _particle_layer
	
	var layers = {
		"wall" : _wall_layer,
		"main" : _main_layer,
		"particle" : _particle_layer,
		"ui" : _ui_layer,
	}
	
	Common.setup(layers, _player)


func _process(delta: float) -> void:
	
	_update_camera()
	
	match _state:
		eState.MAIN:
			for board in _board_list:
				if board.is_hit:
					var type = Window2.eType.FULL
					if _checkbox_window.pressed:
						type = Window2.eType.SMALL
					
					if type == Window2.eType.FULL:
						if Input.is_action_just_pressed("ui_z"):
							_set_process(false)
							_window = WINDOW_OBJ.instantiate()
							_ui_layer.add_child(_window)
							_window.open(type, board.msg_id)
							_state = eState.POP_UP
					else:
						if is_instance_valid(_window) == false:
							_window = WINDOW_OBJ.instantiate()
							_ui_layer.add_child(_window)
						_window.open(type, board.msg_id)
					
		eState.POP_UP:
			if is_instance_valid(_window) == false:
				_set_process(true)
				_state = eState.MAIN
	
	for ui in _ui_list:
		var b = _player.is_idle()
		if ui is Slider:
			ui.editable = b
		else:
			ui.disabled = !b
	
	
	var fps = _hslider_fps.value
	_label_fps.text = "%dFPS"%fps
	Engine.set_time_scale(fps/60.0)

func _set_process(b:bool) -> void:
	_player.set_process(b)
	_player.set_physics_process(b)
	
func _update_camera() -> void:
	if is_instance_valid(_player) == false:
		return
	
	_camera.position.x = _player.position.x

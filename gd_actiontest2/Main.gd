extends Node2D

const WINDOW_ENABLE = false

const WINDOW_OBJ = preload("res://src/common/Window.tscn")
const NASU_OBJ = preload("res://src/enemy/Nasu.tscn")
const NASU2_OBJ = preload("res://src/enemy/Nasu2.tscn")
const TAKO_OBJ = preload("res://src/enemy/Tako.tscn")

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
@onready var _check_nasu = $UILayer/VBoxContainer/Nasu
@onready var _check_nasu2 = $UILayer/VBoxContainer/Nasu2
@onready var _check_tako = $UILayer/VBoxContainer/Tako
@onready var _check_tako2 = $UILayer/VBoxContainer/Tako2
@onready var _check_tako3 = $UILayer/VBoxContainer/Tako3
@onready var _check_tako4 = $UILayer/VBoxContainer/Tako4

var _board_list = []
var _ui_list = []
var _state = eState.MAIN
var _window = null
var _cnt = 0

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
	
	Common.setup(layers, _player, _camera)


func _process(delta: float) -> void:
	_cnt += 1
	
	_update_camera()
	
	_update_enemy()
	
	match _state:
		eState.MAIN:
			if WINDOW_ENABLE:
				_update_main(delta)
					
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

func _update_main(delta:float) -> void:
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

	
func _update_camera() -> void:
	if is_instance_valid(_player) == false:
		return
	
	_camera.position.x = _player.position.x

func _update_enemy() -> void:
	var pos = _camera.position
	pos.x += 1024/2
	if _check_nasu.button_pressed:
		if _cnt%(60 * 4) == 1:
			var nasu = NASU_OBJ.instantiate()
			nasu.setup(pos)
			_main_layer.add_child(nasu)
	if _check_nasu2.button_pressed:
		if _cnt%(60 * 10) == 1:
			var nasu2 = NASU2_OBJ.instantiate()
			_main_layer.add_child(nasu2)
	if _check_tako.button_pressed:
		if _cnt%(60 * 4) == 1:
			if randi()%2 == 0:
				pos.x -= 1024
			var ofs_y = randf_range(-300, 300)
			pos.y += ofs_y
			var tako = TAKO_OBJ.instantiate()
			tako.setup(pos, Tako.eMode.HORMING)
			_main_layer.add_child(tako)
			
	if _check_tako2.button_pressed:
		if _cnt%(60 * 4) == 1:
			if randi()%2 == 0:
				pos.x -= 1024
			var ofs_y = randf_range(-300, 300)
			pos.y += ofs_y
			var tako = TAKO_OBJ.instantiate()
			tako.setup(pos, Tako.eMode.INTERVAL)
			_main_layer.add_child(tako)
	
	if _check_tako3.button_pressed:
		if _count_tako() == 0:
			if randi()%2 == 0:
				pos.x -= 1024
			var ofs_y = randf_range(-300, 300)
			var tako = TAKO_OBJ.instantiate()
			tako.setup(pos, Tako.eMode.MIDDLE_RANGE)
			_main_layer.add_child(tako)
	
	if _check_tako4.button_pressed:
		if _count_tako() == 0:
			if randi()%2 == 0:
				pos.x -= 1024
			var ofs_y = randf_range(-300, 300)
			var tako = TAKO_OBJ.instantiate()
			tako.setup(pos, Tako.eMode.ROUND)
			_main_layer.add_child(tako)

func _count_tako() -> int:
	var ret = 0
	for obj in _main_layer.get_children():
		if not obj is Tako:
			continue
		ret += 1
	return ret

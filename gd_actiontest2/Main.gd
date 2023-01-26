extends Node2D

onready var _player = $Player
onready var _particle_layer = $ParticleLayer

onready var _hslider_fps = $HSliderFPS
onready var _label_fps = $HSliderFPS/Label

var _ui_list = []

func _ready() -> void:
	_ui_list = [
		_hslider_fps,
	]
	Common.layer_particle = _particle_layer


func _process(delta: float) -> void:
	for ui in _ui_list:
		var b = _player.is_idle()
		if ui is Slider:
			ui.editable = b
		else:
			ui.disabled = !b
	
	
	var fps = _hslider_fps.value
	_label_fps.text = "%dFPS"%fps
	Engine.set_time_scale(fps/60.0)

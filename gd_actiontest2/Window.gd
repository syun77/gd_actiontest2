extends Node2D

class_name Window

const TIMER_FULL = 0.5

enum eType {
	FULL,
	SMALL,
}

enum eMsg {
	JUMP,
	DOUBLE_JUMP,
	KEY,
}

onready var _bg = $Bg
onready var _msg = $Message

var _type:int = eType.FULL
var _timer = 0.0

func open(type:int, msg:int) -> void:
	_msg.visible = true
	
	_type = type
	match type:
		eType.FULL:
			_bg.visible = true
			_timer = TIMER_FULL
	
	match msg:
		eMsg.JUMP:
			_msg.bbcode_text = "[center][img=40]res://a_button.png[/img] でジャンプします[/center]"
		eMsg.DOUBLE_JUMP:
			_msg.bbcode_text = "[center]ジャンプ中に[img=40]res://a_button.png[/img] で２段ジャンプします[/center]"	
		eMsg.KEY:
			_msg.bbcode_text = "[center]カギを取るとロックを解除します[/center]"

func _ready() -> void:
	_hide()

func _hide() -> void:
	_bg.visible = false
	_msg.visible = false

func _process(delta: float) -> void:
	match _type:
		eType.FULL:
			_timer = max(0.0, _timer-delta)
			var rate = Ease.expo_out(TIMER_FULL - _timer)
			if _timer <= 0.0:
				if Input.is_action_just_pressed("ui_z"):
					queue_free()


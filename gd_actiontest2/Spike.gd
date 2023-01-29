extends Area2D

onready var _spr = $Spike

var _timer = 0.0
var _cnt = 0

func _ready() -> void:
	_cnt = randi()

func _physics_process(delta: float) -> void:
	_timer += delta
	_cnt += 1
	
	_spr.frame = (_cnt/16)%4
	


func _on_Spike_body_entered(body: Node) -> void:
	if body.has_method("vanish"):
		body.vanish()

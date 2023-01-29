extends Area2D

class_name Board

export var msg_id:int = 0

var is_hit = false

func _on_Board_body_entered(body: Node) -> void:
	if body is Player:
		is_hit = true

func _on_Board_body_exited(body: Node) -> void:
	if body is Player:
		is_hit = false

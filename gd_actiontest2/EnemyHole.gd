extends Area2D

const ENEMY_OBJ = preload("res://Enemy.tscn")

var _timer = 0.0

func _process(delta: float) -> void:
	_timer += delta
	if int(_timer)%3 == 0:
		if _count_enemy() == 0:
			var enemy = ENEMY_OBJ.instance()
			enemy.position = position
			Common.get_layer("main").add_child(enemy)

func _count_enemy() -> int:
	var cnt = 0
	for obj in Common.get_layer("main").get_children():
		if obj is Enemy:
			cnt += 1
	return cnt

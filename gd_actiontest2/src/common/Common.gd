extends Node

const PARTICLE_OBJ = preload("res://src/Particle.tscn")

var is_ghost = false
var is_ghost_mono = false
var is_particle = true
var _player:Player = null
var _player_pos = Vector2.ZERO
var _player_left = false

var layer_particle:CanvasLayer
var _layers = {}
var _camera:Camera2D

func setup(layers, player, camera) -> void:
	_layers = layers
	_player = player
	_camera = camera
	
func get_layer(name:String) -> CanvasLayer:
	return _layers[name]

func get_target_pos() -> Vector2:
	if is_instance_valid(_player) == false:
		return _player_pos
	_player_pos = _player.position
	return _player_pos
func is_target_left() -> bool:
	if is_instance_valid(_player) == false:
		return _player_left
	
	_player_left = _player.is_left
	return _player_left

## 指定のノードが画面内かどうか.
func is_in_screen(node:Node2D) -> bool:
	var size = 64
	var p = node.position
	var left = _camera.position.x - 1024/2
	var right = _camera.position.x + 1024/2
	var top = _camera.position.y - 600/2
	var bottom = _camera.position.y + 600/2
	
	if p.x < left - size:
		return false
	if p.x > right + size:
		return false
	if p.y < top - size:
		return false
	if p.y > bottom + size:
		return false
	return true

func get_camera_pos() -> Vector2:
	return _camera.position

func add_particle(pos:Vector2, vec:Vector2, sc:float, t:float, is_gravity:bool)-> Particle:
	if is_particle == false:
		return null
	var p = PARTICLE_OBJ.instantiate()
	layer_particle.add_child(p)
	p.start(pos, vec, sc, t, is_gravity)
	return p

# 最短の角度差を求める
# @param now 現在の角度
# @param next 目標となる角度
func diff_angle(now:float, next:float) -> float:
	var d = next - now
	d -= floor(d / 360.0) * 360.0
	if d > 180:
		d -= 360
	return d

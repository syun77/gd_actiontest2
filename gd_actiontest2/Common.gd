extends Node

const PARTICLE_OBJ = preload("res://Particle.tscn")

var is_ghost = false
var is_ghost_mono = false
var is_particle = false

var layer_particle:CanvasLayer

func add_particle(pos:Vector2, vec:Vector2, sc:float, t:float, is_gravity:bool)-> Particle:
	if is_particle == false:
		return null
	var p = PARTICLE_OBJ.instance()
	layer_particle.add_child(p)
	p.start(pos, vec, sc, t, is_gravity)
	return p

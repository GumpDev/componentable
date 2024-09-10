@icon("res://addons/componentable/icons/Component.svg")
class_name Node2DComponent extends Node

@export var active = true : set = _set_active
var node_2d: Node2D

func _set_active(_active: bool):
	active = _active
	set_process(active)
	set_process_input(active)
	set_physics_process(active)
	

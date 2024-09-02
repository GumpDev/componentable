class_name ComponentableInspectorTreeComponent extends Node

@export var active = true : set = _set_active
@export var componentable_inspector_tree: ComponentableInspectorTree

func _set_active(_active: bool):
	active = _active
	set_process(active)
	set_process_input(active)
	set_physics_process(active)

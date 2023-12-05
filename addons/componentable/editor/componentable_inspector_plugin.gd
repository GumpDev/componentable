extends EditorInspectorPlugin

const ComponentableInspector = preload("res://addons/componentable/editor/componentable_inspector.tscn")

func _can_handle(object: Object) -> bool:
	return object is Node

func _parse_begin(object: Object) -> void:
	if not object is Node:
		return
	var node: Node = object
	if not ComponentWorker.node_is_component(node):
		var component_inspector := ComponentableInspector.instantiate()
		component_inspector.init(node)
		add_custom_control(component_inspector)

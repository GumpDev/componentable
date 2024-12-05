extends Node

const COMPONENTS_META = "components"

func is_componentable(node: Node):
	if node != null:
		return node.has_meta(COMPONENTS_META)
	return null

func has(node: Node, component_name: String):
	if not is_componentable(node): return false
	return get_all(node).has(component_name)

func get_all(node: Node) -> Dictionary:
	if not is_componentable(node):
		push_error("%s not is a componentable node!" % node.name)
		return {}
	return node.get_meta(COMPONENTS_META)

func find(node: Node, component_name: String):
	if not is_componentable(node):
		push_error("%s not is a componentable node!" % node.name)
		return null
	if not has(node, component_name):
		return null
	return node.get_node(get_all(node)[component_name])

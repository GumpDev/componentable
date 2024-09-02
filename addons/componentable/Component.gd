class_name Component extends Object

static func has(node: Node, component_name: String):
	return ComponentWorker.has_component(node, component_name)

static func get_all(node: Node):
	return ComponentWorker.get_all_components(node)

static func find(node: Node, component_name: String):
	return ComponentWorker.find(node, component_name)

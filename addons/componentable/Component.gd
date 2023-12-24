class_name Component extends Object

static func componentable(node: Node):
	ComponentWorker.componentable(node)

static func uncomponentable(node: Node):
	ComponentWorker.uncomponentable(node)

static func is_componentable(node: Node):
	return ComponentWorker.is_componentable(node)

static func has_component(node: Node, component_name: String):
	return ComponentWorker.has_component(node, component_name)

static func subscribe(node: Node, component_name: String):
	ComponentWorker.subscribe(node, component_name)

static func unsubscribe(node: Node, component_name: String):
	ComponentWorker.unsubscribe(node, component_name)

static func get_all(node: Node):
	return ComponentWorker.get_all_components(node)

static func find(node: Node, component_name: String):
	return ComponentWorker.find(node, component_name)

static func reset_componentable(node: Node):
	ComponentWorker.reset_componentable(node)

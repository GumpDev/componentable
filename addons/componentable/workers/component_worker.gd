extends Node

const COMPONENTS_META = "components"
const COMPONENT_META = "component"

func create_components_node(node: Node):
	if not node.has_node("components"):
		var components_node = Node.new()
		components_node.set_name("components")
		components_node.set_meta(COMPONENT_META, true)
		node.add_child(components_node)
		components_node.set_owner(EditorInterface.get_edited_scene_root())

func remove_components_node(node: Node):
	if len(get_all_components(node)) == 0:
		var components_node = node.get_node("components")
		if components_node:
			components_node.queue_free()

func componentable(node: Node):
	if not is_componentable(node):
		node.set_meta(COMPONENTS_META, {})
	ComponentableFs.create_component(node)
		
func uncomponentable(node: Node):
	if is_componentable(node):
		var components_node = node.get_node("components")
		if components_node: components_node.queue_free()
		node.remove_meta(COMPONENTS_META)

func is_componentable(node: Node):
	if node != null:
		return node.has_meta(COMPONENTS_META)
	return null

func has_component(node: Node, component_name: String):
	if not is_componentable(node): return false
	return get_all_components(node).has(component_name)
	
func subscribe(node: Node, component_name: String):
	if not is_componentable(node):
		componentable(node)
	
	var component = Node.new() 
	component.name = component_name
	component.set_script(load(ComponentableFs.get_class_component(component_name).path))
	component.set_meta(COMPONENT_META, true)
	
	create_components_node(node)
	node.get_node("components").add_child(component)
	component.set_owner(EditorInterface.get_edited_scene_root())
	for cl_name in ComponentableFs.get_parents_class_name(node):
		if cl_name.to_snake_case() in component.get_property_list().map(func (prop): return prop.name):
			component.set(cl_name.to_snake_case(), node)
	
	var components: Dictionary = get_all_components(node)
	components[component_name] = node.get_path_to(component)
	node.set_meta(COMPONENTS_META, components)

func unsubscribe(node: Node, component_name: String):
	var components: Dictionary = get_all_components(node)
	node.get_node(components[component_name]).queue_free()
	components.erase(component_name)
	node.set_meta(COMPONENTS_META, components)
	remove_components_node(node)

func get_all_components(node: Node) -> Dictionary:
	if not is_componentable(node):
		push_error("%s not is a componentable node!" % node.name)
		return {}
	return node.get_meta(COMPONENTS_META)

func find(node: Node, component_name: String):
	if not is_componentable(node):
		push_error("%s not is a componentable node!" % node.name)
		return null
	if not has_component(node, component_name):
		return null
	return node.get_node(get_all_components(node)[component_name])

func node_is_component(node: Node):
	return node.has_meta(COMPONENT_META)

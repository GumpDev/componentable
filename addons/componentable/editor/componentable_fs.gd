class_name ComponentableFs extends Node

static func get_template(node: Node, cl_name: String):
	var file = FileAccess.open("res://addons/componentable/templates/componentable_template.txt", FileAccess.READ)
	var text = file.get_as_text().replace("<type>", cl_name.to_snake_case()).replace("<Type>", cl_name)
	file.close()
	return text

static func get_parents_class_name(node: Node):
	var results = []
	var parent = null
	if not node: return []
	if node.get_script() and node.get_script().get_path():
		results.append(get_custom_class_name(node.get_script().get_path()))
		parent = node.get_script().get_base_script()
		while(parent != null):
			results.append(get_custom_class_name(parent.get_path()))
			if parent.get_base_script() == null:
				results.append(parent.get_instance_base_type())
				var type_parent = ClassDB.get_parent_class(parent.get_instance_base_type())
				results.append(type_parent)
				while(type_parent != "Object"):
					results.append(type_parent)
					type_parent = ClassDB.get_parent_class(type_parent)
				parent = null
	else:
		results.append(node.get_class().get_basename())
		var type_parent = ClassDB.get_parent_class(node.get_class().get_basename())
		while(type_parent != "Object"):
			results.append(type_parent)
			type_parent = ClassDB.get_parent_class(type_parent)
	return results

static func get_class_name(node: Node) -> String:
	if node.get_script() and node.get_script().get_path():
		return get_custom_class_name(node.get_script().get_path())
	return node.get_class().get_basename()

static func get_custom_class_name(path: String):
	for cls in ProjectSettings.get_global_class_list():
		if cls.path == path:
			return cls.class
	return null

static func create_folder():
	if not DirAccess.dir_exists_absolute("res://addons/componentable/components"):
		DirAccess.make_dir_absolute("res://addons/componentable/components")

static func create_component(node: Node):
	create_folder()
	var file = FileAccess.open("res://addons/componentable/components/%s.gd" % get_component_script_name(node), FileAccess.WRITE)
	file.store_string(get_template(node, get_class_name(node)))
	file.close()
	
static func get_component_script_name(node: Node):
	var cl_name = get_class_name(node)
	return "%sComponent" % cl_name

static func remove_component(node: Node):
	var file = DirAccess.remove_absolute("res://addons/componentable/components/%sComponent.gd" % node.get_class().get_basename())

static func get_components(node: Node):
	var parents = get_parents_class_name(node).map(func (cl_name): return "%sComponent" % cl_name)
	return ProjectSettings.get_global_class_list() \
		.filter(func (cls): return cls.base in parents)

static func get_class_component(component_name: String):
	return ProjectSettings.get_global_class_list() \
		.filter(func (cls): return cls.class == component_name)[0]

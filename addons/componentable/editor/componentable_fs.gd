class_name ComponentableFs extends Node

const SUPPORTED_TYPES = [
	TYPE_BOOL,
	TYPE_INT,
	TYPE_FLOAT,
	TYPE_STRING,
	TYPE_STRING_NAME,
	TYPE_NODE_PATH,
	TYPE_ARRAY,
	TYPE_DICTIONARY,
	TYPE_VECTOR2,
	TYPE_VECTOR2I,
	TYPE_VECTOR3,
	TYPE_VECTOR3I,
	TYPE_COLOR
]

static func get_template(node: Node, cl_name: String):
	var file = FileAccess.open("res://addons/componentable/templates/componentable_template.txt", FileAccess.READ)
	var text = file.get_as_text().replace("<type>", cl_name.to_snake_case()).replace("<Type>", cl_name)
	file.close()
	return text

static func get_parents_class_name(node: Node):
	if not node: return []
	var results = []
	var parent = str(node.get_class())
	if node.get_script():
		parent = node.get_script()
	var i = 0
	while parent != null:
		if parent is String:
			results.append(parent)
			if parent == &"Object":
				break
			parent = str(ClassDB.get_parent_class(parent))
		elif parent is Script:
			results.append(str(parent.get_global_name()))
			parent = parent.get_base_script() if parent.get_base_script() else str(parent.get_instance_base_type())
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
	var file_name = "res://addons/componentable/components/%s.gd" % get_component_script_name(node)
	if (FileAccess.file_exists(file_name)): return
	var file = FileAccess.open(file_name, FileAccess.WRITE)
	file.store_string(get_template(node, get_class_name(node)))
	file.close()
	
static func get_component_script_name(node: Node):
	var cl_name = get_class_name(node)
	return "%sComponent" % cl_name

static func remove_component(node: Node):
	var file = DirAccess.remove_absolute("res://addons/componentable/components/%sComponent.gd" % node.get_class().get_basename())

static func get_properties(node: Node):
	if not node.get_script():
		return []
	return node.get_script().get_script_property_list().filter(func (p): return p['usage'] & PROPERTY_USAGE_STORAGE)

static func get_components(node: Node):
	var parents = get_parents_class_name(node).map(func (cl_name): return "%sComponent" % cl_name)
	return ProjectSettings.get_global_class_list() \
		.filter(func (cls): return cls.base in parents)

static func get_class_component(component_name: String):
	return ProjectSettings.get_global_class_list() \
		.filter(func (cls): return cls.class == component_name)[0]

static func delete_component(path: String):
	DirAccess.remove_absolute(path)
	EditorInterface.get_resource_filesystem().scan()

static func create_component_file(path: String, name: String, node: Node):
	create_component(node)
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string("class_name %s extends %s" % [name.split(".")[0], get_component_script_name(node)])
	file.close()
	EditorInterface.get_resource_filesystem().scan()
	EditorInterface.edit_script(load(path))

static func is_valid(path: String):
	return FileAccess.file_exists(path)

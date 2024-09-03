@tool
class_name ComponentableInspectorTree extends Tree

var root: TreeItem
var node: Node
var create_button: TreeItem

func _enter_tree() -> void:
	EditorInterface.get_selection().selection_changed.connect(_selected_nodes)
	item_activated.connect(_create_button)
	item_edited.connect(_item_edited)
	
func _exit_tree() -> void:
	EditorInterface.get_selection().selection_changed.disconnect(_selected_nodes)
	item_activated.disconnect(_create_button)
	item_edited.disconnect(_item_edited)

func _selected_nodes():
	var nodes = EditorInterface.get_selection().get_selected_nodes()
	create_root()
	
	if len(nodes) != 1: 
		select_error()
		return
	
	node = nodes[0]
	var components = ComponentableFs.get_components(node)
	
	if len(components) == 0:
		empty_error()
	else:
		for item in components:
			create_component_item(item.class)
		
	create_create_component()

func _item_edited():
	var item = get_edited()
	
	if item.get_parent() == root:
		if item.is_checked(0):
			ComponentWorker.subscribe(node, item.get_text(0))
		else:
			ComponentWorker.unsubscribe(node, item.get_text(0))
		update_properties(item)

func create_root():
	clear()
	set_column_title(0, "Components")
	columns = 1
	column_titles_visible = true
	root = create_item()
	hide_root = true

func select_error():
	var item = create_item()
	item.set_text(0, "Select one node to see the components!")
	item.set_text_alignment(0, HORIZONTAL_ALIGNMENT_CENTER)

func empty_error():
	var item = create_item()
	item.set_text(0, "This node has no components!")
	item.set_text_alignment(0, HORIZONTAL_ALIGNMENT_CENTER)

func create_component_item(name: String):
	var item = create_item()
	item.set_selectable(0, true)
	item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
	item.set_text(0, name)
	item.set_editable(0, true)
	item.set_checked(0, ComponentWorker.has_component(node, name))
	update_properties(item)
	
func update_properties(item: TreeItem):
	if ComponentWorker.has_component(node, item.get_text(0)):
		var component = ComponentWorker.find(node, item.get_text(0))
		if not component: return
		create_components_properties(component, item)
	else:
		for c in item.get_children():
			item.remove_child(c)
			c.free()

func create_components_properties(component: Node, root_item: TreeItem):
	var exports = ComponentWorker.get_exports(component)
	for property in exports:
		var item = root_item.create_child()
		if property.type == 1:
			item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
			item.set_editable(0, true)
		item.set_text(0, property.name)
		print(property)
		
func create_create_component():
	var spacer = create_item()
	spacer.set_text(0, " ")
	spacer.set_selectable(0, false)
	create_button = create_item()
	create_button.set_text(0, "Create Component")
	create_button.set_text_alignment(0, HORIZONTAL_ALIGNMENT_CENTER)
	
func _create_button():
	if create_button.is_selected(0):
		var file_dialog = FileDialog.new()
		file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
		file_dialog.filters = ["*.gd"]
		add_child(file_dialog)
		file_dialog.popup_centered()
		file_dialog.confirmed.connect(func (): ComponentableFs.create_component_file(file_dialog.current_path, file_dialog.current_file, node))
		file_dialog.close_requested.connect(func (): file_dialog.queue_free())
		

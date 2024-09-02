@tool
class_name ComponentableInspectorTree extends Tree

var root: TreeItem
var node: Node
var create_button: TreeItem

func _enter_tree() -> void:
	EditorInterface.get_selection().selection_changed.connect(_selected_nodes)
	item_activated.connect(_create_button)
	
func _exit_tree() -> void:
	EditorInterface.get_selection().selection_changed.disconnect(_selected_nodes)
	item_activated.disconnect(_create_button)

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

func create_root():
	clear()
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
		

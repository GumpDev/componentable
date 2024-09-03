@tool
class_name ComponentableInspectorTree extends Tree

@export var file_dialog: FileDialog
@export var remove_component_dialog: ConfirmationDialog

var root: TreeItem
var node: Node
var create_button: TreeItem
var removed_item: TreeItem

func _enter_tree() -> void:
	EditorInterface.get_selection().selection_changed.connect(_selected_nodes)
	item_activated.connect(_create_button)
	item_edited.connect(_item_edited)
	file_dialog.close_requested.connect(func (): file_dialog.hide())
	remove_component_dialog.close_requested.connect(func (): remove_component_dialog.hide())
	remove_component_dialog.confirmed.connect(remove_component)
	
func _exit_tree() -> void:
	EditorInterface.get_selection().selection_changed.disconnect(_selected_nodes)
	if item_activated.is_connected(_create_button):
		item_activated.disconnect(_create_button)
	if item_edited.is_connected(_item_edited):
		item_edited.disconnect(_item_edited)
	if remove_component_dialog.confirmed.is_connected(remove_component):
		remove_component_dialog.confirmed.disconnect(remove_component)

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
	if item.get_metadata(0) and item.get_metadata(0)['type'] == "component":
		if item.is_checked(0):
			ComponentWorker.subscribe(node, item.get_text(0))
		else:
			item.set_checked(0, true)
			removed_item = item
			remove_component_dialog.popup_centered()

func remove_component():
	if not removed_item: return
	removed_item.set_checked(0, false)
	ComponentWorker.unsubscribe(node, removed_item.get_text(0))
	removed_item = null

func create_root():
	clear()
	columns = 1
	column_titles_visible = true
	set_column_title(0, "Components")
	root = create_item()
	root.set_expand_right(0, true)
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
	item.set_metadata(0, {
		type = "component"
	})
	item.set_editable(0, true)
	item.set_checked(0, ComponentWorker.has_component(node, name))
		
func create_create_component():
	var spacer = create_item()
	spacer.set_text(0, " ")
	spacer.set_selectable(0, false)
	create_button = create_item()
	create_button.set_text(0, "Create Component")
	create_button.set_text_alignment(0, HORIZONTAL_ALIGNMENT_CENTER)
	
func _create_button():
	if create_button.is_selected(0):
		file_dialog.popup_centered()
		file_dialog.confirmed.connect(func (): ComponentableFs.create_component_file(file_dialog.current_path, file_dialog.current_file, node))
		
		

@tool
class_name ComponentableInspectorTree extends Control

@export var componentable_btn: Button
@export var recomponentable_btn: Button
@export var non_componentable: VBoxContainer
@export var components_tree: Tree
@export var componentable_display: VBoxContainer

var node: Node

func init(_node: Node):
	node = _node

func _ready():
	if Component.is_componentable(node):
		non_componentable.hide()
		componentable_display.show()
		recomponentable_btn.connect("button_down", _on_clicked_recomponentable)
		create_components_list()
	else:
		componentable_display.hide()
		non_componentable.show()
		componentable_btn.connect("button_down", _on_clicked_componentable)

func create_components_list():
	if len(ComponentableFs.get_components(node)) == 0:
		var txt = Label.new()
		txt.text = "No components found for this componentable"
		txt.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		txt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		return
	
	for component in ComponentableFs.get_components(node):
		var checkbutton = CheckButton.new()
		checkbutton.text = component.class
		checkbutton.button_up.connect(func ():
			if checkbutton.button_pressed:
				Component.subscribe(node, component.class)
			else:
				Component.unsubscribe(node, component.class)
		)

func _on_clicked_componentable():
	Component.componentable(node)
	
func _on_clicked_recomponentable():
	var confirmation = ConfirmationDialog.new()
	confirmation.dialog_text = "You really want to reset the componentable? (this action will reset all components and your values)"
	confirmation.confirmed.connect(func ():
		ComponentWorker.reset_componentable(node)
	)
	get_tree().root.add_child(confirmation)
	confirmation.popup_centered()

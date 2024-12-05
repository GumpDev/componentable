@tool
extends EditorPlugin

var componentable_ui: Control

func _enter_tree():
	componentable_ui = preload("res://addons/componentable/editor/componentable_inspector.tscn").instantiate()
	add_autoload_singleton("Component", "res://addons/componentable/Component.gd")
	add_control_to_dock(DockSlot.DOCK_SLOT_RIGHT_UL, componentable_ui)

func _exit_tree():
	remove_control_from_docks(componentable_ui)
	remove_autoload_singleton("Component")

@tool
extends EditorPlugin

@warning_ignore("untyped_declaration")
var PLUGIN = preload("res://addons/SecondOrderResponseChart/Inspector_editor_charts.gd")
var plugin:EditorInspectorPlugin
func _enter_tree() -> void:
	plugin = PLUGIN.new()
	add_inspector_plugin(plugin)


func _exit_tree() -> void:
	remove_inspector_plugin(plugin)

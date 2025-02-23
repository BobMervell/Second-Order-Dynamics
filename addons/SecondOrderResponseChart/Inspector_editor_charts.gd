extends EditorInspectorPlugin

const second_order_plotter = preload("res://addons/SecondOrderResponseChart/SecondOrderPlotter.gd")
var plotter_instance

func _can_handle(object):
	return true

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if name.contains('second_order'):
		plotter_instance = second_order_plotter.new()
		add_custom_control(plotter_instance)
		plotter_instance.object = object
		plotter_instance.prop_name = name
		plotter_instance.on_inspector_edited_object_changed(name)

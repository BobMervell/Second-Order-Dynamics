extends EditorInspectorPlugin

signal command_type_updated(item_id:int)

var second_order_configs:Dictionary

## every object can handle
func _can_handle(_object: Object) -> bool:
	return true

func _parse_begin(_object:Object) -> void:
	second_order_configs.clear()

## Creates a chart plot instance if @export var type is SecondOrderSystem
func _parse_property(_object: Object, _type: Variant.Type, name: String, _hint_type: PropertyHint,
		 hint_string: String, _usage_flags:PropertyUsageFlags, _wide: bool) -> bool:
	
	if name.contains("second_order_config"):
		var config_id:String = name.get_slice('_',0)
		var chart_slider_instance:SecondOrderSliders = SecondOrderSliders.new()
		var label:String = "Second order config " + config_id
		add_property_editor(name,chart_slider_instance,false,label)
		second_order_configs[config_id] = chart_slider_instance
		return true

	if hint_string.contains("SecondOrderSystem"):
		var config_id:String = name.get_slice('_',0)
		var corresponding_chart_slider:SecondOrderSliders
		if second_order_configs.has(config_id):
			corresponding_chart_slider = second_order_configs[config_id]
		else:
			push_warning("Second order system plugin error:\n
				Unable to find corresponding config for: " + name.to_upper() + 
				"\n See second order system for correct implementation.")
	
		var chart_plot_instance:SecondOrderPlotter = SecondOrderPlotter.new()
		add_custom_control(chart_plot_instance)
		chart_plot_instance.update_chart_weights(corresponding_chart_slider.weights)
		corresponding_chart_slider.weights_updated.connect(chart_plot_instance.update_chart_weights)
		command_type_updated.connect(chart_plot_instance.update_chart_type)
		add_custom_control(add_graph_command_type())
		return true
	return false

func add_graph_command_type() -> HBoxContainer:
	var parent:HBoxContainer = HBoxContainer.new()
	var text:Label = Label.new()
	var obtion_btn:OptionButton = OptionButton.new()
	parent.add_child(text)
	parent.add_child(obtion_btn)
	text.text = "Input command: "
	obtion_btn.add_item("Step",0)
	obtion_btn.add_item("Complex",1)
	obtion_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	obtion_btn.item_selected.connect(item_value_updated)
	return parent

func item_value_updated(item_id:int) -> void:
	command_type_updated.emit(item_id)

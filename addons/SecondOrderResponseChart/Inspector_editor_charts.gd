extends EditorInspectorPlugin

signal command_type_updated(item_id)

var second_order_configs:Dictionary

## every object can handle
func _can_handle(object: Object) -> bool:
	return true

func _parse_begin(object:Object):
	second_order_configs.clear()

## Creates a chart plot instance if @export var type is SecondOrderSystem
func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint,
		 hint_string: String, usage_flags:PropertyUsageFlags, wide: bool) -> bool:
	
	if name.contains("second_order_config"):
		var config_id = name.get_slice('_',0)
		var chart_slider_instance = SecondOrderSliders.new()
		var label:String = "Second order config " + config_id
		add_property_editor(name,chart_slider_instance,false,label)
		second_order_configs[config_id] = chart_slider_instance
		return true

	if hint_string.contains("SecondOrderSystem"):
		var config_id = name.get_slice('_',0)
		var corresponding_chart_slider:SecondOrderSliders
		if second_order_configs.has(config_id):
			corresponding_chart_slider = second_order_configs[config_id]
		else:
			push_warning("error couldn't find config for second order system")
	
		var chart_plot_instance = SecondOrderPlotter.new()
		add_custom_control(chart_plot_instance)
		chart_plot_instance.object = object
		chart_plot_instance.prop_name = name
		chart_plot_instance.update_chart_weights(corresponding_chart_slider.weights)
		corresponding_chart_slider.weights_updated.connect(chart_plot_instance.update_chart_weights)
		command_type_updated.connect(chart_plot_instance.update_chart_type)
		add_custom_control(add_graph_command_type())
		return true
	return false

func add_graph_command_type() -> HBoxContainer:
	var parent :=HBoxContainer.new()
	var text := Label.new()
	var obtion_btn := OptionButton.new()
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

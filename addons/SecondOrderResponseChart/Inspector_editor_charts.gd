extends EditorInspectorPlugin

signal command_type_updated(item_id:int)
signal simuation_duration_updated(nbr_pts:float)
signal simuation_precision_updated(nbr_pts:float)


var second_order_configs:Dictionary

## every object can handle
func _can_handle(_object: Object) -> bool:
	return true

func _parse_begin(_object:Object) -> void:
	second_order_configs.clear()

## Creates a chart plot instance if @export var type is SecondOrderSystem
func _parse_property(_object: Object, _type: Variant.Type, name: String, _hint_type: PropertyHint,
		 hint_string: String, _usage_flags:PropertyUsageFlags, _wide: bool) -> bool:
	
	if name.contains("config"):
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
		chart_plot_instance.update_chart_weights(corresponding_chart_slider.weights)
		corresponding_chart_slider.weights_updated.connect(chart_plot_instance.update_chart_weights)
		command_type_updated.connect(chart_plot_instance.update_chart_type)
		simuation_precision_updated.connect(chart_plot_instance.update_simuation_precision)
		simuation_duration_updated.connect(chart_plot_instance.update_simuation_duration)
		add_custom_control(add_graph_command_type())
		add_custom_control(chart_plot_instance)
		add_custom_control(add_time_slider())
		add_custom_control(add_precision_slider())
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

func add_time_slider() -> HBoxContainer:
	var parent:HBoxContainer = HBoxContainer.new()
	var slider:EditorSpinSlider = EditorSpinSlider.new()
	var slider_label:Label = Label.new()
	slider_label.text = "Simulation duration "

	slider.max_value = 10
	slider.min_value = .1
	slider.value = 2.1
	slider.exp_edit = true
	slider.value_changed.connect(time_slider_updated)
	slider.step = .01
	slider.rounded = false
	slider.allow_greater = true
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.set_tooltip_text("Duration or the chart simulation. \n
			Note: \n
			- Higher values have en impact on editor frame rate \n
			- If response time approximation = inf, try setting a higher value")
	parent.add_child(slider_label)
	parent.add_child(slider)
	return parent

func add_precision_slider() -> HBoxContainer:
	var parent:HBoxContainer = HBoxContainer.new()
	var slider:EditorSpinSlider = EditorSpinSlider.new()
	var slider_label:Label = Label.new()
	slider_label.text = "Simulation precision "

	slider.max_value = 5
	slider.min_value = 0.5
	slider.value = 1.5
	slider.exp_edit = true
	slider.value_changed.connect(precision_slider_updated)
	slider.step = .01
	slider.allow_greater = true
	slider.allow_lesser = true
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	parent.add_child(slider_label)
	parent.add_child(slider)
	parent.set_tooltip_text("Precision or the chart simulation, the in game precision is defined by delta. \n
			Note: \n
			- If visual artifact appears you need to set the precision lower.
			- Lower values have an impact on editor frame rate. ")
	return parent

func time_slider_updated(value:float) -> void:
	simuation_duration_updated.emit(value)

func precision_slider_updated(value:float) -> void:
	value = max(value,0.01)
	simuation_precision_updated.emit(value)

func item_value_updated(item_id:int) -> void:
	command_type_updated.emit(item_id)

@tool
extends EditorProperty
class_name SecondOrderSliders

signal weights_updated(weights:Dictionary)

var k_slider:EditorSpinSlider
var wo_slider:EditorSpinSlider
var xi_slider:EditorSpinSlider
var z_slider:EditorSpinSlider
var weights:Dictionary = {"k":1,"wo":40,"xi":1,"z":0}

func _init() -> void :
	var parent:VBoxContainer = VBoxContainer.new()
	k_slider = add_graph_weight("k",-2,2,.1,1)
	wo_slider = add_graph_weight("wo",0,300,.01,40)
	xi_slider = add_graph_weight("xi",0,10,.01,1)
	z_slider =add_graph_weight("z",-2,2,.001,0)
	parent.add_child(k_slider)
	parent.add_child(wo_slider)
	parent.add_child(xi_slider)
	parent.add_child(z_slider)
	add_child(parent)

func _ready() -> void:
	var old_weights:Dictionary = get_edited_object().get(get_edited_property())
	if old_weights.size() == 4:
		weights = old_weights
	get_edited_object().set(get_edited_property(),weights)
	weights_updated.emit(weights)
	emit_changed(get_edited_property(),weights)
	
	

func add_graph_weight(weight_name:String,min_value:float,max_value:float,step:float,export_value:float) -> EditorSpinSlider:
	var float_slider:EditorSpinSlider = EditorSpinSlider.new()
	float_slider.label =  weight_name
	float_slider.min_value = min_value
	float_slider.max_value = max_value
	float_slider.step = step
	float_slider.value = export_value
	float_slider.allow_greater = true
	float_slider.allow_lesser = true
	float_slider.exp_edit = true
	float_slider.value_changed.connect(slider_value_changed.bind(weight_name))
	return float_slider

func _update_property() -> void:
	@warning_ignore("unsafe_method_access")
	weights = get_edited_object().get(get_edited_property()).duplicate(true)
	if weights.size() <4:
		weights = {"k":1.,"wo":40.,"xi":1.,"z":0.}
	weights_updated.emit(weights)
	for elt:String in weights:
		if elt == "k":
			k_slider.value = weights["k"]
		elif elt == "wo":
			wo_slider.value = weights["wo"]
		elif elt == "xi":
			xi_slider.value = weights["xi"]
		elif elt == "z":
			z_slider.value = weights["z"]

func slider_value_changed(new_value:float,weight_name:String) -> void:
	weights[weight_name] = new_value
	get_edited_object().set(get_edited_property(),weights)
	weights_updated.emit(weights)
	emit_changed(get_edited_property(),weights)

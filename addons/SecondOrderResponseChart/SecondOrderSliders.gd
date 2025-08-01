@tool
extends EditorProperty
class_name SecondOrderSliders

signal weights_updated(weights:Dictionary)

var k_slider:EditorSpinSlider
var wo_slider:EditorSpinSlider
var xi_slider:EditorSpinSlider
var z_slider:EditorSpinSlider
var delta_slider:EditorSpinSlider
var T_slider:EditorSpinSlider
const DEFAULT_WEIGHTS:Dictionary = {"k":1,"wo":40,"xi":1,"z":0,"delta_err":.9,"T_offset":0}
var weights:Dictionary = DEFAULT_WEIGHTS.duplicate()

func _init() -> void :
	var parent:VBoxContainer = VBoxContainer.new()
	k_slider = add_graph_weight("k",-2,2,.1,1)
	wo_slider = add_graph_weight("wo",0,300,.01,40)
	xi_slider = add_graph_weight("xi",0,10,.01,1)
	z_slider = add_graph_weight("z",-1,1,.0001,0)
	delta_slider = add_graph_weight("delta_err",0,2,.0001,.9)
	T_slider = add_graph_weight("T_offset",0,2,.001,0)

	parent.add_child(k_slider)
	parent.add_child(wo_slider)
	parent.add_child(xi_slider)
	parent.add_child(z_slider)
	parent.add_child(delta_slider)
	parent.add_child(T_slider)
	add_child(parent)

func _ready() -> void:
	var old_weights:Dictionary = get_edited_object().get(get_edited_property())
	if are_unordered_dict_keys_equal(old_weights,DEFAULT_WEIGHTS):
		weights = old_weights
	else:
		push_warning("AAAAAASecond order system weights incorrect, default: ",
				str(DEFAULT_WEIGHTS),
				"  will replace old value of: ", str(weights) )
		weights = DEFAULT_WEIGHTS.duplicate()
	
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
	if not are_unordered_dict_keys_equal(weights,DEFAULT_WEIGHTS):
		weights = DEFAULT_WEIGHTS.duplicate()
		get_edited_object().set(get_edited_property(), weights)
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
		elif elt == "delta_err":
			delta_slider.value = weights["delta_err"]
		elif elt == "T_offset":
			T_slider.value = weights["T_offset"]

func slider_value_changed(new_value:float,weight_name:String) -> void:
	weights[weight_name] = new_value
	get_edited_object().set(get_edited_property(),weights)
	weights_updated.emit(weights)
	emit_changed(get_edited_property(),weights)

## Checks if keys are the same size and all keys of a have a corresponding key in b
func are_unordered_dict_keys_equal(dict_a:Dictionary,dict_b:Dictionary) -> bool:
	var keys_a = dict_a.keys()
	var keys_b = dict_b.keys()
	if keys_a.size() != keys_b.size():
		return false
	for elt in keys_a:
		if not keys_b.has(elt):
			return false
		else: keys_b.erase(elt)
	return true
